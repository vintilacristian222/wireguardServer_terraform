locals {
  server_ip = hcloud_server.wg_server.ipv4_address 
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.wg_keys.private_key_pem
  filename = "/home/mvintila/myTfKeyrsa"  # change this to your mac/ubuntu ssh keys location
}

#Create ssh key in hcloud
resource "hcloud_ssh_key" "terraform" {
  name       = "Terraform"
  public_key = tls_private_key.wg_keys.public_key_openssh
}

# Generate WireGuard keys
resource "tls_private_key" "wg_keys" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create Ubuntu server on Hetzner
resource "hcloud_server" "wg_server" {
  name        = "wg-server-4" 
  image       = "ubuntu-20.04"
  server_type = "cx11"
  ssh_keys = [hcloud_ssh_key.terraform.id]

  # Install WireGuard
  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install -y wireguard",
      "apt update",
      "apt install -y wireguard",
      "umask 077",   # keys created without restrictions 
      "wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey",
      "echo '[Interface]' > /etc/wireguard/wg0.conf",
      "PRIVATE_KEY=$(cat /etc/wireguard/privatekey)",
      "echo \"PrivateKey = $PRIVATE_KEY\" >> /etc/wireguard/wg0.conf",
      "echo 'Address = 10.0.0.1/24' >> /etc/wireguard/wg0.conf",
      "echo 'ListenPort = 51820' >> /etc/wireguard/wg0.conf",
      "echo '[Peer]' >> /etc/wireguard/wg0.conf",
      "echo 'AllowedIPs = 10.0.0.2/32' >> /etc/wireguard/wg0.conf",
      "echo 'PublicKey = ${var.client_public_key}' >> /etc/wireguard/wg0.conf",
      "ufw disable",
      "systemctl enable wg-quick@wg0"
    ]
    connection {
        type     = "ssh"
        user     = "root"  
        host     =  hcloud_server.wg_server.ipv4_address
        private_key = tls_private_key.wg_keys.private_key_pem   # change this to your mac/ubuntu ssh keys location
    }
  }
  depends_on = [ local_file.ssh_private_key ]

}

# fetching the public key with scp 

resource "null_resource" "fetch_public_key" {
  provisioner "local-exec" {
    command = <<EOT
      echo "${tls_private_key.wg_keys.private_key_pem}" > private_key.pem
      chmod 600 private_key.pem
      sleep 10s
      scp -o StrictHostKeyChecking=no -i  private_key.pem root@${local.server_ip}:/etc/wireguard/publickey .
      rm private_key.pem 
    EOT
  }
  depends_on = [local_file.ssh_private_key]
}


resource "null_resource" "read_public_key" {
  triggers = {
    content = fileexists("publickey") ? trim(file("publickey"), "\n") : ""
  }
  depends_on = [null_resource.fetch_public_key]
}

# WireGuard client config edit the public key endpoint  so that it reflects your domain record 
data "template_file" "wg_client_config" {
  template = <<EOF
[Interface]
PrivateKey = ${var.client_private_key}
Address = 10.0.0.2/24

[Peer]  
PublicKey = ${null_resource.read_public_key.triggers.content}
AllowedIPs = 0.0.0.0/0
Endpoint = ${local.server_ip}:51820         
EOF
}

resource "local_file" "wg_client_config" {
  content  = data.template_file.wg_client_config.rendered
  filename = "wg0-client.conf" 
}



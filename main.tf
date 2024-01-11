locals {
  server_ip = hcloud_server.wg_server.ipv4_address 
}

# Fetch an existing SSH key from your Hetzner account
data "hcloud_ssh_key" "existing" {
  name = "cristi@TheBeastV3"  # Replace with your existing SSH key name
}

resource "hcloud_server" "wg_server" {
  name        = "wg-server-4" 
  image       = "ubuntu-20.04"
  server_type = "cx11"
  ssh_keys    = [data.hcloud_ssh_key.existing.id]

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install -y wireguard",
      "umask 077",
      "wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey",
      "echo '[Interface]' > /etc/wireguard/wg0.conf",
      "PRIVATE_KEY=$(cat /etc/wireguard/privatekey)",
      "echo \"PrivateKey = $PRIVATE_KEY\" >> /etc/wireguard/wg0.conf",
      "echo 'Address = 10.0.0.1/24' >> /etc/wireguard/wg0.conf",
      "echo 'ListenPort = 51820' >> /etc/wireguard/wg0.conf",
      "echo '[Peer]' >> /etc/wireguard/wg0.conf",
      "echo 'PublicKey = ${var.client_public_key}' >> /etc/wireguard/wg0.conf",
      "echo 'AllowedIPs = 10.0.0.2/32' >> /etc/wireguard/wg0.conf",
      "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",
      "sysctl -p",
      "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      "iptables -A FORWARD -i wg0 -j ACCEPT",
      "iptables -A FORWARD -o wg0 -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "ufw disable",
      "systemctl enable wg-quick@wg0",
      "systemctl start wg-quick@wg0"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = self.ipv4_address
      private_key = file("C:/Users/Cristi/.ssh/id_rsa")  # Replace with the path to your private key
    }
  }
}

resource "null_resource" "fetch_public_key" {
  provisioner "local-exec" {
    command = <<EOT
      scp -o StrictHostKeyChecking=no -i C:/Users/Cristi/.ssh/id_rsa root@${local.server_ip}:/etc/wireguard/publickey publickey
    EOT
  }
  depends_on = [hcloud_server.wg_server]
}

resource "local_file" "wg_client_config" {
  content = templatefile("${path.module}/wg0-client.tpl", {
    client_private_key = var.client_private_key,  # Replace with your client's WireGuard private key
    server_public_key = fileexists("publickey") ? file("publickey") : "",
    server_ip = local.server_ip
  })
  filename = "wg0-client.conf"
  depends_on = [null_resource.fetch_public_key]
}

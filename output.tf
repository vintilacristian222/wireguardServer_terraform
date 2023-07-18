output "wg_public_key" {
  value = null_resource.read_public_key.triggers.content
}


output "wg_server_ip" {
  value = hcloud_server.wg_server.ipv4_address
}


output "ssh_private_key" {
  description = "The SSH private key"
  value       = tls_private_key.wg_keys.private_key_pem
  sensitive = true
}


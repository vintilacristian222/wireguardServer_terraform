

output "wg_server_ip" {
  value = hcloud_server.wg_server.ipv4_address
}

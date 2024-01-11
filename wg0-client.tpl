[Interface]
PrivateKey = ${client_private_key}
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = ${server_public_key}
AllowedIPs = 10.0.0.0/24, 0.0.0.0/0, ::/0
Endpoint = ${server_ip}:51820
PersistentKeepalive = 25

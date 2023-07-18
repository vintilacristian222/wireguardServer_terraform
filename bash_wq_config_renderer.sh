#!/bin/bash

# Save the server IP to a variable
server_ip=$(terraform output -raw server_ip)

# Save the server IP to a file
output_file="output.txt"
echo "$server_ip" > "$output_file"

# Extract the content of the publickey file
public_key_file="publickey"
public_key=$(cat "$public_key_file")

# Generate the WireGuard client configuration
client_private_key="<client_private_key>"
client_config_file="/etc/wireguard/wg0-client.conf"
cat <<EOF > "$client_config_file"
[Interface]
PrivateKey = $client_private_key
Address = 10.0.0.2/24

[Peer]
PublicKey = $public_key
AllowedIPs = 0.0.0.0/0
Endpoint = $server_ip:51820
EOF

# Print the generated configuration
cat "$client_config_file"

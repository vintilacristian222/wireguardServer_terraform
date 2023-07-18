#!/bin/bash

# Read the private key from the file
client_private_key=$(cat /etc/wireguard/privatekey)

# Read the public key from the file
client_public_key=$(cat /etc/wireguard/publickey)

# Replace the default values in the variables.tf file
sed -i "s/default_client_private_key/$client_private_key/g" variables.tf
sed -i "s/default_client_public_key/$client_public_key/g" variables.tf

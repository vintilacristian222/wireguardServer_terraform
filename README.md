
# Terraform Configuration for WireGuard Server Setup

This Terraform configuration is designed to create and set up a WireGuard server on Hetzner Cloud (HCloud).

## Overview

The `main.tf` file contains the following resources:

1. **SSH Key Configuration:** Generates an SSH key and assigns the public key to a new Hetzner Cloud SSH key resource.
2. **WireGuard Key Generation:** Generates a new private key for WireGuard.
3. **Server Configuration:** Creates a new server on Hetzner Cloud, and then installs WireGuard.
4. **Fetch Public Key:** Fetches the public key from the server.
5. **Read Public Key:** Reads the fetched public key and stores it in a local variable.
6. **WireGuard Client Config:** Sets up the WireGuard client configuration and writes it to a file.

## Prerequisites

1. Install [Terraform](https://www.terraform.io/downloads.html)
2. [Hetzner Cloud Account](https://accounts.hetzner.com/register)
3. [Hetzner Cloud Token](https://docs.hetzner.cloud/#overview-getting-started)
4. Install [WireGuard Client](https://www.wireguard.com/install/)

## Usage

**Initial Setup**

1. **Install WireGuard Client:** Install the WireGuard client on your machine. Follow the instructions on the [WireGuard Install](https://www.wireguard.com/install/) page.

2. **Replace API Token:** Replace the placeholder for the Hetzner Cloud API token in the provider configuration with your actual API token.

3. **Run publicPrivateKeySwitcher.sh:** Run the `publicPrivateKeySwitcher.sh` script. This script is necessary for managing the keys needed for the WireGuard client and server to communicate securely. It reads the private and public keys from the WireGuard configuration on your machine and replaces placeholders in the `variables.tf` Terraform file with these keys. The script assumes that your private and public keys are located in `/etc/wireguard/` and are named `privatekey` and `publickey` respectively. If your keys are located elsewhere or have different names, you will need to modify the script to match your configuration.

**Terraform Configuration**

Before you can use this configuration, make sure to replace `"C:/Users/Cristi/.ssh/terraform_id_rsa_2"` in the `local_file.ssh_private_key` resource with the path to where you want to store your SSH keys.

Once you have done that, follow these steps:

1. **Initialize Terraform:** Run `terraform init` in the directory that contains `main.tf`. This will download the necessary provider plugins.

2. **Plan the Deployment:** Run `terraform plan` to see what resources Terraform will create.

3. **Apply the Configuration:** Run `terraform apply` to create the resources. Terraform will prompt you to confirm that you want to create the resources, type `yes` to confirm.

After running `terraform apply`, Terraform will create a WireGuard server on Hetzner Cloud and output the client configuration.

## Output

The configuration will produce a `wg0-client.conf` file, which contains the client configuration for the WireGuard VPN. You can use this file to set up a WireGuard client to connect to the VPN.

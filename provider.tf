terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.41.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "hcloud" {
  # Configuration options
  token =""  # switch this your own token 
  endpoint = "https://api.hetzner.cloud/v1" # The API endpoint to use (optional, default is https://api.hetzner.cloud/v1)
  poll_interval = "500ms" # The interval to poll for resource updates (optional, default is 500ms)
}


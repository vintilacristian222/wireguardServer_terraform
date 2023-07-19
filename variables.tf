variable "client_private_key" {
  description = "The client's private key"
  type        = string
  default     =  var.CLIENT_PRIVATE_KEY
}

variable "client_public_key" {
  description = "The client's public key"
  type        = string
  default     =  var.CLIENT_PUBLIC_KEY
}

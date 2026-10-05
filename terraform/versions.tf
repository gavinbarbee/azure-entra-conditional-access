terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Authenticates as sp-gavinbarbee-terraform-ca.
# ARM_CLIENT_ID and ARM_CLIENT_SECRET are read from environment variables
# in the terminal session, so the secret never touches a file in the repo.
provider "azuread" {
  tenant_id = var.tenant_id
}

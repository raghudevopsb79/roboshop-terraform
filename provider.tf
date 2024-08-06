provider "vault" {
  address         = "https://vault-internal.rdevopsb79.online:8200"
  skip_tls_verify = true
  token           = var.vault_token
}

terraform {
  backend "s3" {}
}


provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


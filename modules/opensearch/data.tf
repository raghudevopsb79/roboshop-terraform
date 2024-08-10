data "vault_generic_secret" "opensearch" {
  path = "common/opensearch"
}

data "aws_caller_identity" "current" {}


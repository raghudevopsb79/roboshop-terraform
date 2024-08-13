data "aws_caller_identity" "current" {}

data "external" "oidc-thumbprint" {
  program = ["kubergrunt", "eks", "oidc-thumbprint", "--issuer-url", aws_eks_cluster.main.identity[0].oidc[0].issuer]
}

data "vault_generic_secret" "opensearch" {
  path = "common/opensearch"
}

data "template_file" "logstash-input" {
  template = file("${path.module}/conf/fluentd.yaml")
  vars = {
    DOMAIN_USER = data.vault_generic_secret.opensearch.data["MASTER_USERNAME"]
    DOMAIN_PASS = data.vault_generic_secret.opensearch.data["MASTER_PASSWORD"]
    DOMAIN_URL  = var.opensearch_url
    ENV         = var.env
  }
}

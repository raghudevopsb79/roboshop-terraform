data "aws_caller_identity" "current" {}

data "external" "oidc-thumbprint" {
  program = ["kubergrunt", "eks", "oidc-thumbprint", "--issuer-url", aws_eks_cluster.main.identity[0].oidc[0].issuer ]
}


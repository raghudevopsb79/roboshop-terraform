locals {
  OIDC_PROVIDER = split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]
}


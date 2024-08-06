resource "aws_eks_cluster" "main" {
  name     = "${var.name}-${var.env}-eks"
  role_arn = aws_iam_role.eks-role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}


data "aws_iam_policy_document" "eks-assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks-role" {
  name               = "${var.name}-${var.env}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks-assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role_policy_attachment" "eks-role-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-role.name
}


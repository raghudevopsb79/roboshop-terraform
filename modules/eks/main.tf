resource "aws_eks_cluster" "main" {
  name     = "${var.name}-${var.env}-eks"
  role_arn = aws_iam_role.eks-role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

# resource "aws_eks_node_group" "main" {
#   for_each        = var.node_groups
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = each.key
#   node_role_arn   = aws_iam_role.node-role.arn
#   subnet_ids      = var.subnet_ids
#
#   scaling_config {
#     desired_size = each.value["min_nodes"]
#     max_size     = each.value["max_nodes"]
#     min_size     = each.value["min_nodes"]
#   }
# }


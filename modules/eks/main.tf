resource "aws_eks_cluster" "main" {
  name     = "${var.name}-${var.env}-eks"
  role_arn = aws_iam_role.eks-role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

}

resource "aws_eks_node_group" "main" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = var.subnet_ids
  capacity_type   = each.value["capacity_type"]
  instance_types  = each.value["instance_types"]

  scaling_config {
    desired_size = each.value["min_nodes"]
    max_size     = each.value["max_nodes"]
    min_size     = each.value["min_nodes"]
  }

  lifecycle {
    ignore_changes = [
      scaling_config["desired_size"]
    ]
  }

}

resource "aws_eks_addon" "add_ons" {
  for_each                    = var.add_ons
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.key
  addon_version               = each.value["addon_version"]
  resolve_conflicts_on_update = each.value["resolve_conflicts_on_update"]
}

resource "aws_iam_openid_connect_provider" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [data.external.oidc-thumbprint.result.thumbprint]
}


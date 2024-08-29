module "network" {
  for_each = var.vpc
  source   = "./modules/network"

  cidr               = each.value["cidr"]
  subnets            = each.value["subnets"]
  availability_zones = each.value["availability_zones"]
  peering_vpcs       = each.value["peering_vpcs"]

  env = var.env
}

module "db" {
  source   = "./modules/ec2"
  for_each = var.db_servers

  env           = var.env
  bastion_nodes = var.bastion_nodes
  zone_id       = var.zone_id
  vault_token   = var.vault_token

  name          = each.key
  ports         = each.value["ports"]
  instance_type = each.value["instance_type"]

  vpc_id     = module.network["main"].vpc_id
  subnet_ids = module.network["main"].subnets["db"].subnets
}

module "eks" {
  source   = "./modules/eks"
  for_each = var.eks

  env = var.env

  eks_version = each.value["eks_version"]
  name        = each.key
  node_groups = each.value["node_groups"]
  add_ons     = each.value["add_ons"]

  subnet_ids          = module.network["main"].subnets[each.value["subnet_ref"]].subnets
  opensearch_url      = module.opensearch["main"].opensearch_url
  eks_iam_role_access = each.key["eks_iam_role_access"]
}

module "opensearch" {
  source   = "./modules/opensearch"
  for_each = var.opensearch

  env = var.env

  engine_version = each.value["engine_version"]
  instance_type  = each.value["instance_type"]
  name           = each.key

}


module "network" {
  for_each = var.vpc
  source   = "./modules/network"

  cidr    = each.value["cidr"]
  subnets = each.value["subnets"]

  env = var.env
}


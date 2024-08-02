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

module "app" {
  source     = "./modules/docker"
  for_each   = var.app_servers
  depends_on = [module.db]

  env           = var.env
  bastion_nodes = var.bastion_nodes
  zone_id       = var.zone_id
  vault_token   = var.vault_token

  name          = each.key
  ports         = each.value["ports"]
  instance_type = each.value["instance_type"]

  vpc_id     = module.network["main"].vpc_id
  subnet_ids = module.network["main"].subnets["app"].subnets
}

module "web" {
  source     = "./modules/docker"
  for_each   = var.web_servers
  depends_on = [module.app]

  env           = var.env
  bastion_nodes = var.bastion_nodes
  zone_id       = var.zone_id
  vault_token   = var.vault_token

  name          = each.key
  ports         = each.value["ports"]
  instance_type = each.value["instance_type"]

  vpc_id     = module.network["main"].vpc_id
  subnet_ids = module.network["main"].subnets["web"].subnets
}

module "load-balancers" {
  source   = "./modules/load-balancers"
  for_each = var.load_balancers

  name               = each.key
  load_balancer_type = each.value["load_balancer_type"]
  internal           = each.value["internal"]

  vpc_id      = module.network["main"].vpc_id
  subnet_ids  = module.network["main"].subnets["public"].subnets
  instance_id = module.web["frontend"].instance_id

  env = var.env
}


locals {
  peering_target_cidr = [for k, v in var.peering_vpcs : v["cidr"]]
  peering_ids         = [for k, v in aws_vpc_peering_connection.peers : v["id"]]
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Name = "${var.env}-vpc"
  }

}

module "subnets" {
  source   = "./subnets"
  for_each = var.subnets

  name = each.key
  cidr = each.value["cidr"]

  availability_zones = var.availability_zones
  env                = var.env

  vpc_id = aws_vpc.vpc.id
}


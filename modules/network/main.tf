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

resource "aws_eip" "ngw" {
  count  = length(var.availability_zones)
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.ngw.*.id[count.index]
  subnet_id     = module.subnets["public"].subnets[count.index]

  tags = {
    Name = "ngw-${split("-", var.availability_zones[count.index])[2]}"
  }
}





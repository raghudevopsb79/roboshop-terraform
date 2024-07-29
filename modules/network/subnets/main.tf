resource "aws_subnet" "subnet" {
  count             = length(var.cidr)
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.name}-${var.env}-${split("-", var.availability_zones[count.index])[2]}"
  }
}


resource "aws_route_table" "route-table" {
  count  = length(var.cidr)
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-${var.env}-${split("-", var.availability_zones[count.index])[2]}"
  }
}


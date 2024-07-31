output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets" {
  value = module.subnets
}


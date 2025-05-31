locals {
  vpc_name = "${var.app_name}-vpc"
  endpoints = {
    ssm = {
      name = "ssm"
    },
    ssmmessages = {
      name = "ssmmessages"
    },
    ec2messages = {
      name = "ec2messages"
    }
  }
  azs = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))

  public_subnet_map  = zipmap(local.azs, var.public_subnet_cidrs)
  private_subnet_map = zipmap(local.azs, var.private_subnet_cidrs)

  nat_gateway_azs = var.multi_az_nat_gateway ? local.azs : [local.azs[0]]
}
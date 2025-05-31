#######################
# VPC                 #
#######################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
  }
}

############################
# Public subnets - tier 1  #
############################
resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key

  for_each = local.public_subnet_map

  tags = {
    Name = "public-${each.key}-${each.value}"
  }
}

############################
# Private subnets - tier 2 #
############################
resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key

  for_each = local.private_subnet_map

  tags = {
    Name = "private-${each.key}-${each.value}"
  }
}

#####################################
# Internet gateway                  #
#####################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${local.vpc_name}"
  }
}

#####################################
# Public RT and association         #
#####################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-${local.vpc_name}"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  for_each = aws_subnet.public_subnets

  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

#####################################
# NAT Gateway and it's EIP          #
#####################################
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "eip-nat-${local.vpc_name}"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_subnets[keys(local.public_subnet_map)[0]].id


  tags = {
    Name = "nat-${local.vpc_name}"
  }

  depends_on = [aws_internet_gateway.igw]
}

#####################################
# Private RT and association        #
#####################################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt-${local.vpc_name}"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = aws_subnet.private_subnets

  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_rt.id
}

#####################################
# RDS Subnet Group                  #
#####################################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subgroup-${local.vpc_name}"
  subnet_ids = values(aws_subnet.private_subnets)[*].id

  tags = {
    Name = "rds-mysql-${local.vpc_name}"
  }
}
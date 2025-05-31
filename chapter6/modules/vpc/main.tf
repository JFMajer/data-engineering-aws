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
  for_each = toset(local.nat_gateway_azs)

  domain = "vpc"

  tags = {
    Name = "eip-nat-${each.key}-${local.vpc_name}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = toset(local.nat_gateway_azs)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id


  tags = {
    Name = "nat-${each.key}-${local.vpc_name}"
  }

  depends_on = [aws_internet_gateway.igw]
}

#####################################
# Private RT and association        #
#####################################
resource "aws_route_table" "private_rt" {
  for_each = aws_subnet.private_subnets

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.multi_az_nat_gateway ? aws_nat_gateway.nat[each.key].id : aws_nat_gateway.nat[local.azs[0]].id
  }

  tags = {
    Name = "private-rt-${each.key}-${local.vpc_name}"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = aws_subnet.private_subnets

  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_rt[each.key].id
}

#####################################
# RDS Subnet Group                  #
#####################################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subgroup-${local.vpc_name}"
  subnet_ids = values(aws_subnet.private_subnets)[*].id

  tags = {
    Name = "rds-mysql-${local.vpc_name}"
  }
}

#####################################
# DMS Subnet Group                  #
#####################################
resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  replication_subnet_group_id          = "dms-subgroup-${local.vpc_name}"
  subnet_ids                           = values(aws_subnet.private_subnets)[*].id
  replication_subnet_group_description = "Subnet group for DMS replication in ${local.vpc_name}"

  tags = {
    Name = "dms-${local.vpc_name}"
  }
}

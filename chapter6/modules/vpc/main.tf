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
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = element(var.availability_zones, count.index)

  count = var.public_subnets_count

  tags = {
    Name = "public_10.0.${count.index + 10}.0_${element(var.availability_zones, count.index)}"
  }
}

############################
# Private subnets - tier 2 #
############################
resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = element(var.availability_zones, count.index)

  count = var.private_subnets_count

  tags = {
    Name = "private_10.0.${count.index + 20}.0_${element(var.availability_zones, count.index)}"
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
  count          = var.public_subnets_count
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
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
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)

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
  count          = var.private_subnets_count
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

#####################################
# RDS Subnet Group                  #
#####################################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-sub_group-${local.vpc_name}"
  subnet_ids = aws_subnet.private_subnets.*.id

  tags = {
    Name = "rds-mysql-${local.vpc_name}"
  }
}
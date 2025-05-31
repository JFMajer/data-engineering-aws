output "ssm_endpoint_ids" {
  description = "IDs of the SSM VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.ssm_endpoint : k => v.id }
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  description = "value of the public subnets ids"
  value       = [for s in values(aws_subnet.public_subnets) : s.id]
}

output "private_subnets_ids" {
  description = "value of the private subnets ids"
  value       = [for s in values(aws_subnet.private_subnets) : s.id]
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  value       = [for s in values(aws_subnet.private_subnets) : s.cidr_block]
}

output "private_subnets_azs" {
  description = "List of availability zones for private subnets"
  value       = [for s in values(aws_subnet.private_subnets) : s.availability_zone]
}

output "rds_subnet_group_id" {
  description = "ID of the RDS subnet group"
  value       = aws_db_subnet_group.rds_subnet_group.id
}

output "rds_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "nat_gateway_ids" {
  value = { for k, nat in aws_nat_gateway.nat : k => nat.id }
}

output "dms_subnet_group_id" {
  description = "ID of the DMS subnet group"
  value       = aws_dms_replication_subnet_group.dms_subnet_group.replication_subnet_group_id
}



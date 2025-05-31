output "ssm_endpoint_ids" {
  description = "IDs of the SSM VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.ssm_endpoint : k => v.id }
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  value       = aws_subnet.private_subnets[*].cidr_block
}

output "private_subnets_azs" {
  description = "Availability zones of private subnets"
  value       = aws_subnet.private_subnets[*].availability_zone
}

output "rds_subnet_group_id" {
  description = "ID of the RDS subnet group"
  value       = aws_db_subnet_group.rds_subnet_group.id
}

output "rds_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (if created)"
  value       = try(aws_nat_gateway.nat.id, null)
}

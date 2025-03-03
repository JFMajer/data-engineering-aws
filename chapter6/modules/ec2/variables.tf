variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for EC2 instance"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the secret containing RDS master user password"
  type        = string
}

variable "rds_id" {
  description = "ID of the RDS instance to create dependency"
  type        = string
}
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance (in GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "sakila"
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the RDS instance"
  type        = list(string)
  default     = []
}
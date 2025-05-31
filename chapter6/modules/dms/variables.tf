variable "name_prefix" {
  description = "Prefix for naming DMS resources"
  type        = string
}

variable "instance_class" {
  description = "DMS replication instance class"
  type        = string
  default     = "dms.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage (GB) for DMS instance"
  type        = number
  default     = 50
}

variable "db_username" {
  description = "Database username for source MariaDB"
  type        = string
}

variable "db_password" {
  description = "Database password for source MariaDB"
  type        = string
  sensitive   = true
}

variable "rds_address" {
  description = "RDS instance endpoint for MariaDB source"
  type        = string
}

variable "rds_port" {
  description = "RDS port for MariaDB source"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Database name on the source MariaDB"
  type        = string
}

variable "lz_bucket_name" {
  description = "S3 bucket name for landing zone (target for DMS)"
  type        = string
}

variable "dms_s3_access_role_arn" {
  description = "IAM Role ARN that allows DMS to write to S3 bucket"
  type        = string
}

variable "table_mappings_file" {
  description = "Path to JSON file with table mappings for DMS task"
  type        = string
  default     = "table-mappings.json"
}

variable "dms_subnet_group_id" {
  description = "DMS replication subnet group ID"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
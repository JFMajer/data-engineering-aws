variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "env" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets_count" {
  type    = number
  default = 2
}

variable "private_subnets_count" {
  type    = number
  default = 2
}


variable "availability_zones" {
  type    = list(any)
  default = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}
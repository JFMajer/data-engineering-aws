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
}
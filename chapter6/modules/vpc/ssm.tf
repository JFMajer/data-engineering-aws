resource "aws_security_group" "ssm" {
  name        = "${var.app_name}-ssm-${var.env}"
  description = "Security group for SSM"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSM traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ssm-${var.env}"
  }
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  for_each = local.endpoints

  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.${each.value.name}"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.ssm.id]
  subnet_ids         = module.vpc.private_subnets

  private_dns_enabled = true

  tags = {
    Name = "${var.app_name}-${each.value.name}-endpoint-${var.env}"
  }
}
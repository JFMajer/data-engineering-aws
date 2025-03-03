resource "aws_security_group" "ssm" {
  name        = "${var.app_name}-ssm-${var.env}"
  description = "Security group for SSM"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSM traffic from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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

  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.${var.region}.${each.value.name}"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.ssm.id]
  subnet_ids         = aws_subnet.private_subnets[*].id

  private_dns_enabled = true

  tags = {
    Name = "${var.app_name}-${each.value.name}-endpoint-${var.env}"
  }
}
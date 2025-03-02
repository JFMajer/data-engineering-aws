resource "aws_db_instance" "mysql" {
  identifier                  = "${var.name_prefix}-mysql"
  engine                      = "mariadb"
  engine_version              = "11.4.4"
  instance_class              = var.db_instance_class
  allocated_storage           = var.allocated_storage
  storage_type                = "gp3"
  manage_master_user_password = true
  db_name                     = var.db_name
  parameter_group_name        = "default.mariadb11.4.4"
  skip_final_snapshot         = true
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.rds.id]
  db_subnet_group_name        = var.db_subnet_group_name
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
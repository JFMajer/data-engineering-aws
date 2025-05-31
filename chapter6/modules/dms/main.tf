resource "aws_dms_replication_instance" "dms_instance" {
  replication_instance_id     = "${var.name_prefix}-dms-instance"
  replication_instance_class  = var.instance_class # e.g., "dms.t3.medium"
  allocated_storage           = 50
  vpc_security_group_ids      = [aws_security_group.dms_sg.id]
  publicly_accessible         = false
  replication_subnet_group_id = var.dms_subnet_group_id
  tags = {
    Name = "${var.name_prefix}-dms-instance"
  }
}


resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.name_prefix}-source-endpoint"
  endpoint_type = "source"
  engine_name   = "mariadb"
  username      = var.db_username
  password      = var.db_password
  server_name   = var.rds_address
  port          = var.rds_port
  database_name = var.db_name
}

resource "aws_dms_s3_endpoint" "target" {
  endpoint_id             = "${var.name_prefix}-target-endpoint"
  endpoint_type           = "target"
  bucket_name             = var.lz_bucket_name
  service_access_role_arn = var.dms_s3_access_role_arn

  compression_type  = "NONE"
  csv_delimiter     = ","
  csv_row_delimiter = "\n"
  add_column_name   = true
}


resource "aws_dms_replication_task" "migration" {
  replication_task_id      = "${var.name_prefix}-migration-task"
  replication_instance_arn = aws_dms_replication_instance.dms_instance.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_s3_endpoint.target.endpoint_arn

  migration_type = "full-load"                                # or "cdc", or "full-load-and-cdc"
  table_mappings = file("${path.module}/table-mappings.json") # JSON file describing which tables to migrate

  tags = {
    Name = "${var.name_prefix}-migration-task"
  }
}

resource "aws_security_group" "dms_sg" {
  name        = "${var.name_prefix}-dms-sg"
  description = "Security group for AWS DMS replication instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-dms-sg"
  }
}

module "vpc" {
  app_name = "chapter6"
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  env      = "dev"
  public_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
  private_subnet_cidrs = [
    "10.0.20.0/24",
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
  multi_az_nat_gateway = false
}

module "rds" {
  source = "./modules/rds"

  name_prefix          = "chapter6"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.rds_subnet_group_id
  allowed_cidr_blocks  = module.vpc.private_subnet_cidrs
}

module "ec2" {
  source         = "./modules/ec2"
  name_prefix    = "chapter6"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.private_subnets_ids[0]
  rds_address    = module.rds.rds_address
  db_username    = module.rds.rds_username
  rds_secret_arn = module.rds.rds_secret_arn
  rds_id         = module.rds.rds_id
}

module "s3_bucket_lz" {
  source        = "./modules/s3-bucket"
  bucket_prefix = "data-engineering-6-lz"
}

module "s3_bucket_cz" {
  source        = "./modules/s3-bucket"
  bucket_prefix = "data-engineering-6-cz"
}

resource "aws_lambda_layer_version" "lambda_layer_wrangler" {
  layer_name = "awswrangler_layer_3_11_0_py3_13"
  filename   = "awswrangler-layer-3.11.0-py3.13.zip"
}

module "lambda_function" {
  source           = "./modules/lambda"
  bucket_lz_name   = module.s3_bucket_lz.bucket_name
  bucket_cz_name   = module.s3_bucket_cz.bucket_name
  lambda_layer_arn = aws_lambda_layer_version.lambda_layer_wrangler.arn
}

module "kinesis_firehose" {
  source                  = "./modules/kinesis-firehose"
  delivery_s3_bucket_arn  = module.s3_bucket_lz.bucket_arn
  delivery_s3_bucket_name = module.s3_bucket_lz.bucket_name
}

data "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id = module.rds.rds_secret_arn
}

locals {
  rds_secret_json = jsondecode(data.aws_secretsmanager_secret_version.rds_secret.secret_string)

  rds_username = local.rds_secret_json.username
  rds_password = local.rds_secret_json.password
}

module "dms" {
  source = "./modules/dms"

  name_prefix         = "chapter6"
  instance_class      = "dms.t3.medium"
  vpc_id              = module.vpc.vpc_id
  allocated_storage   = 50
  dms_subnet_group_id = module.vpc.dms_subnet_group_id

  db_username = module.rds.rds_username
  db_password = local.rds_password
  rds_address = module.rds.rds_address
  rds_port    = 3306
  db_name     = "sakila"

  lz_bucket_name         = module.s3_bucket_lz.bucket_name
  dms_s3_access_role_arn = aws_iam_role.dms_s3_role.arn

  table_mappings_file = "${path.module}/table-mappings.json"
}



# 1. Assume Role policy used for all DMS roles
data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dms.amazonaws.com"]
    }
  }
}

# 2. DMS VPC Role - AWS managed policy for VPC access
resource "aws_iam_role" "dms_vpc_role" {
  name               = "dms-vpc-role"
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role_attach" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# 3. DMS CloudWatch Logs Role - AWS managed policy for logs
resource "aws_iam_role" "dms_cloudwatch_logs_role" {
  name               = "dms-cloudwatch-logs-role"
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_logs_role_attach" {
  role       = aws_iam_role.dms_cloudwatch_logs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}

# 4. Your custom S3 access role (keep as is, just clean formatting)
resource "aws_iam_role" "dms_s3_role" {
  name               = "dms-s3-role"
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
}

resource "aws_iam_policy" "dms_s3_policy" {
  name = "dms-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:*"]
      Resource = [
        module.s3_bucket_lz.bucket_arn,
        "${module.s3_bucket_lz.bucket_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dms_s3_role_attach_policy" {
  role       = aws_iam_role.dms_s3_role.name
  policy_arn = aws_iam_policy.dms_s3_policy.arn
}

resource "aws_iam_role" "dms-access-for-endpoint" {
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
  name               = "dms-access-for-endpoint"
}

resource "aws_iam_role_policy_attachment" "dms-access-for-endpoint-AmazonDMSRedshiftS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms-access-for-endpoint.name
}

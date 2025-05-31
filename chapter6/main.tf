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
  rds_address   = module.rds.rds_address
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


resource "aws_iam_role" "dms_s3_role" {
  name = "dms-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "dms_s3_policy" {
  name = "dms-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          module.s3_bucket_lz.bucket_arn,
          "${module.s3_bucket_lz.bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.dms_s3_role.name
  policy_arn = aws_iam_policy.dms_s3_policy.arn
}

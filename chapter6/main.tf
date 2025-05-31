module "vpc" {
  app_name = "chapter6"
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  env      = "dev"
  public_subnet_cidrs = {
    "eu-north-1a" = "10.0.10.0/24"
    "eu-north-1b" = "10.0.11.0/24"
    "eu-north-1c" = "10.0.12.0/24"
  }
  private_subnet_cidrs = {
    "eu-north-1a" = "10.0.20.0/24"
    "eu-north-1b" = "10.0.21.0/24"
    "eu-north-1c" = "10.0.22.0/24"
  }
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
  rds_endpoint   = module.rds.rds_endpoint
  db_username    = module.rds.rds_username
  rds_secret_arn = module.rds.rds_secret_arn
  rds_id         = module.rds.rds_id
}
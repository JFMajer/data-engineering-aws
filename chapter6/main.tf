module "vpc" {
  app_name              = "chapter6"
  source                = "./modules/vpc"
  vpc_cidr              = "10.0.0.0/16"
  public_subnets_count  = 2
  private_subnets_count = 2
  env                   = "dev"
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
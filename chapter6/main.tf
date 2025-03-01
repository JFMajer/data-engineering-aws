module "vpc" {
    app_name = "chapter6"
    source = "./modules/vpc"
    vpc_cidr = "10.0.0.0/16"
    public_subnets_count = 2
    private_subnets_count = 2
    env = "dev"
}
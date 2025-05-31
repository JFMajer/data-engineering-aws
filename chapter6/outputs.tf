output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_address" {
  value = module.rds.rds_address
}

output "s3_bucket_lz_arn" {
  value = module.s3_bucket_lz.bucket_arn
}
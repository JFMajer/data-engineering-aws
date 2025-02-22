module "s3_bucket_lz" {
  source        = "./modules/s3-bucket"
  bucket_prefix = "data-engineering-3-lz"
}

module "s3_bucket_cz" {
  source        = "./modules/s3-bucket"
  bucket_prefix = "data-engineering-3-cz"
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
variable "bucket_lz_name" {
  description = "Name of the landing zone S3 bucket"
  type        = string
}

variable "bucket_cz_name" {
  description = "Name of the clean zone S3 bucket"
  type        = string
}

variable "lambda_layer_arn" {
  description = "ARN of the Lambda layer to be used by the Lambda function"
  type        = string
}
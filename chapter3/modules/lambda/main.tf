resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "IAM policy for Lambda execution with permissions for logs, s3, and glue"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::${var.bucket_lz_name}/*",
          "arn:aws:s3:::${var.bucket_lz_name}",
          "arn:aws:s3:::${var.bucket_cz_name}/*",
          "arn:aws:s3:::${var.bucket_cz_name}"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["glue:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.13"
  layers        = [var.lambda_layer_arn]

  filename         = "modules/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("modules/lambda/lambda_function.zip")

  timeout     = 300
  memory_size = 512

  environment {
    variables = {
      BUCKET_LZ_NAME = var.bucket_lz_name
      BUCKET_CZ_NAME = var.bucket_cz_name
    }
  }
}

# Lambda Permissions: Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  function_name = aws_lambda_function.my_lambda.function_name
  source_arn    = "arn:aws:s3:::${var.bucket_lz_name}"
}

# S3 Notification: Set up the trigger for object creation events in LZ bucket
resource "aws_s3_bucket_notification" "lz_bucket_notification" {
  bucket = var.bucket_lz_name # LZ bucket name from variables

  lambda_function {
    events              = ["s3:ObjectCreated:*"]            # Trigger when objects are created
    filter_prefix       = ""                                # Optional: Filter by prefix, if needed (e.g., "data/")
    filter_suffix       = ".csv"                            # Optional: Trigger only on CSV files
    lambda_function_arn = aws_lambda_function.my_lambda.arn # Lambda ARN
  }
}
output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_username" {
  value = aws_db_instance.mysql.username
}

output "rds_secret_arn" {
  value = aws_db_instance.mysql.master_user_secret[0].secret_arn
}

output "rds_id" {
  value = aws_db_instance.mysql.id
}
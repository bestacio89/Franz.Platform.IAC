output "rds_endpoint" {
  description = "RDS endpoint when a relational database is selected."
  value       = try(aws_db_instance.microservice_rds[0].endpoint, null)
}

output "rds_db_name" {
  description = "RDS database name when a relational database is selected."
  value       = try(aws_db_instance.microservice_rds[0].db_name, null)
}

output "dynamodb_table_name" {
  description = "DynamoDB table name when DynamoDB is selected."
  value       = try(aws_dynamodb_table.microservice_dynamodb[0].name, null)
}

output "database_type_used" {
  description = "Type of database deployed."
  value       = var.database_type
}

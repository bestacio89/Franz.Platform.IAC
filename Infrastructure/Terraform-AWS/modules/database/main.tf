#######################################
# Global AWS Database Module
# Supports RDS relational engines and DynamoDB.
#######################################

resource "aws_db_instance" "microservice_rds" {
  count               = contains(["postgres", "mysql", "mariadb", "oracle", "sqlserver"], var.database_type) ? 1 : 0
  allocated_storage   = var.db_allocated_storage
  storage_type        = "gp3"
  engine              = var.database_type
  engine_version      = var.db_version
  instance_class      = var.db_instance_class
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  publicly_accessible = var.db_public_access
  skip_final_snapshot = false
  deletion_protection = var.environment == "prod"

  tags = merge(
    var.common_tags,
    { Name = "${var.microservice_name}-rds" }
  )
}

resource "aws_dynamodb_table" "microservice_dynamodb" {
  count        = var.database_type == "dynamodb" ? 1 : 0
  name         = "${var.microservice_name}-${var.dynamodb_table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.microservice_name}-dynamodb" }
  )
}

output "rds_endpoint" {
  description = "RDS endpoint when a relational database is selected."
  value       = try(aws_db_instance.microservice_rds[0].endpoint, null)
}

output "dynamodb_table_name" {
  description = "DynamoDB table name when DynamoDB is selected."
  value       = try(aws_dynamodb_table.microservice_dynamodb[0].name, null)
}

output "vpc_id" {
  description = "VPC ID from networking module"
  value       = module.networking.vpc_id
}

output "kafka_broker" {
  description = "Kafka broker endpoints when Kafka is enabled"
  value       = try(module.kafka[0].kafka_broker, null)
}

output "rabbitmq_endpoints" {
  description = "RabbitMQ broker endpoints when RabbitMQ is enabled"
  value       = try(module.rabbitmq[0].rabbitmq_endpoints, null)
}

output "database_endpoint" {
  description = "RDS endpoint when a relational database is selected"
  value       = module.database.rds_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name when DynamoDB is selected"
  value       = module.database.dynamodb_table_name
}

output "compute_cluster_name" {
  description = "ECS cluster name"
  value       = module.compute.ecs_cluster_name
}

output "compute_service_name" {
  description = "ECS service name"
  value       = module.compute.ecs_service_name
}

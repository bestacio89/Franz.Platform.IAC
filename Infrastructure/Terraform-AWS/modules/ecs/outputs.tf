#######################################
# ECS Outputs
#######################################
output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = try(aws_ecs_cluster.microservice_cluster.id, null)
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = try(aws_ecs_cluster.microservice_cluster.name, null)
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = try(aws_ecs_task_definition.microservice_task.arn, null)
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = try(aws_ecs_service.microservice_service.name, null)
}

output "ecs_service_id" {
  description = "ECS service ID"
  value       = try(aws_ecs_service.microservice_service.id, null)
}

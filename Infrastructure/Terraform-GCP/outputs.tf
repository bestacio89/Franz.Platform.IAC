########################################
# Networking
########################################
output "vpc_id" {
  value       = module.networking.vpc_id
  description = "VPC ID for networking"
}

########################################
# Database
########################################
output "database_endpoint" {
  value       = module.database.db_endpoint
  description = "Database connection endpoint"
}

########################################
# Messaging
########################################
output "messaging_summary" {
  description = "Active messaging endpoints for this environment"

  value = {
    kafka = contains(["kafka", "both"], var.messaging_type) ? {
      cluster_id         = try(module.kafka[0].kafka_cluster_id, null)
      bootstrap_endpoint = try(module.kafka[0].kafka_bootstrap_endpoint, null)
    } : null

    rabbitmq = contains(["rabbitmq", "both"], var.messaging_type) ? {
      service_ip      = try(module.rabbitmq[0].rabbitmq_service_ip, null)
      amqp_port       = try(module.rabbitmq[0].rabbitmq_amqp_port, null)
      management_port = try(module.rabbitmq[0].rabbitmq_management_port, null)
      admin_user      = var.rabbitmq_user
    } : null
  }
}

########################################
# Microservices
########################################
output "microservice_url" {
  value       = module.microservices.service_url
  description = "Microservice URL exposed by the selected compute module"
}

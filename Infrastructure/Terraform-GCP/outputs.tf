output "vpc_id" {
  description = "VPC ID for networking"
  value       = module.networking.vpc_id
}

output "database_endpoint" {
  description = "Database endpoint or connection identifier"
  value = (
    var.database_type == "cloudsql" ? module.database.cloudsql_connection_name :
    var.database_type == "mongo_atlas" ? module.database.mongo_atlas_cluster_uri :
    var.database_type == "mongo_vm" ? module.database.mongo_vm_public_ip :
    module.database.firestore_database_name
  )
  sensitive = var.database_type == "mongo_atlas"
}

output "messaging_summary" {
  description = "Active messaging endpoints for this environment"
  value = {
    kafka = contains(["kafka", "both"], var.messaging_type) ? {
      cluster_id = var.use_gke_kafka ? null : try(module.confluent_kafka[0].kafka_cluster_id, null)
      endpoint   = var.use_gke_kafka ? try(module.gke_kafka[0].kafka_gke_service_ip, null) : try(module.confluent_kafka[0].kafka_bootstrap_endpoint, null)
    } : null
    rabbitmq = contains(["rabbitmq", "both"], var.messaging_type) ? {
      service_ip      = try(module.rabbitmq[0].rabbitmq_service_ip, null)
      amqp_port       = try(module.rabbitmq[0].rabbitmq_amqp_port, null)
      management_port = try(module.rabbitmq[0].rabbitmq_management_port, null)
      admin_user      = var.rabbitmq_user
    } : null
  }
}

output "microservice_url" {
  description = "Microservice URL exposed by the selected compute module"
  value       = var.use_gke ? try(module.gke_microservices[0].service_url, null) : try(module.cloudrun[0].service_url, null)
}

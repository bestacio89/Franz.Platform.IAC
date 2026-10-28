variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "microservice_name" {
  description = "Name of the microservice"
  type        = string
}

variable "common_tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "messaging_type" {
  description = "Messaging layer to deploy: Kafka, RabbitMQ, Both, or None"
  type        = string
  default     = "None"
  validation {
    condition     = contains(["Kafka", "RabbitMQ", "Both", "None"], var.messaging_type)
    error_message = "messaging_type must be Kafka, RabbitMQ, Both, or None."
  }
}

variable "use_msk" {
  description = "Whether to deploy Amazon MSK when Kafka is selected"
  type        = bool
  default     = true
}

variable "rabbitmq_user" {
  description = "RabbitMQ admin username"
  type        = string
  default     = "admin"
}

variable "rabbitmq_password" {
  description = "RabbitMQ admin password"
  type        = string
  sensitive   = true
}

variable "database_type" {
  description = "Database type: postgres, mysql, mariadb, oracle, sqlserver, or dynamodb"
  type        = string
  validation {
    condition     = contains(["postgres", "mysql", "mariadb", "oracle", "sqlserver", "dynamodb"], var.database_type)
    error_message = "database_type must be a supported RDS engine or dynamodb."
  }
}

variable "db_version" {
  description = "Database engine version"
  type        = string
  default     = "16.4"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "microservice"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "db_allocated_storage" {
  description = "Allocated RDS storage in GB"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "container_image" {
  description = "Immutable container image reference for the workload"
  type        = string
}

variable "ecs_execution_role" {
  description = "IAM execution role ARN for ECS tasks"
  type        = string
}

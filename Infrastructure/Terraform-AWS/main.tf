provider "aws" {
  region = var.aws_region
}

module "networking" {
  source            = "./modules/networking"
  microservice_name = var.microservice_name
  common_tags       = var.common_tags
}

module "kafka" {
  count              = contains(["Kafka", "Both"], var.messaging_type) ? 1 : 0
  source             = "./modules/kafka"
  use_msk            = var.use_msk
  microservice_name  = var.microservice_name
  subnet_ids         = [module.networking.public_subnet_id]
  security_group_ids = [module.networking.security_group_id]
  common_tags        = var.common_tags
}

module "rabbitmq" {
  count              = contains(["RabbitMQ", "Both"], var.messaging_type) ? 1 : 0
  source             = "./modules/RabbitMQ"
  enable_rabbitmq    = true
  microservice_name  = var.microservice_name
  common_tags        = var.common_tags
  rabbitmq_user      = var.rabbitmq_user
  rabbitmq_password  = var.rabbitmq_password
  security_group_ids = [module.networking.security_group_id]
  subnet_ids         = [module.networking.public_subnet_id]
}

module "database" {
  source               = "./modules/database"
  microservice_name    = var.microservice_name
  common_tags          = var.common_tags
  database_type        = var.database_type
  db_version           = var.db_version
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_allocated_storage = var.db_allocated_storage
  db_instance_class    = var.db_instance_class
}

module "compute" {
  source             = "./modules/ecs"
  aws_region         = var.aws_region
  microservice_name  = var.microservice_name
  container_image    = var.container_image
  ecs_execution_role = var.ecs_execution_role
  ecs_service_sg     = module.networking.security_group_id
  subnet_ids         = [module.networking.public_subnet_id]
  common_tags        = var.common_tags
}

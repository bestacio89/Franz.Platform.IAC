provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

module "networking" {
  source     = "./modules/networking"
  gcp_region = var.gcp_region
  vpc_name   = "${var.microservice_name}-${var.environment}"
  enable_ssh = false
}

module "database" {
  source                    = "./modules/database"
  database_type             = var.database_type
  db_region                 = var.gcp_region
  db_username               = var.db_username
  db_password               = var.db_password
  db_instance_name          = "${var.microservice_name}-${var.environment}-db"
  mongodb_atlas_public_key  = var.mongodb_atlas_public_key
  mongodb_atlas_private_key = var.mongodb_atlas_private_key
  mongodb_org_id            = var.mongodb_org_id
}

module "cloudrun" {
  count                 = var.use_gke ? 0 : 1
  source                = "./modules/cloudrun"

  gcp_region            = var.gcp_region
  microservice_name     = "${var.microservice_name}-${var.environment}"
  container_image       = var.container_image
  allow_unauthenticated = false
}

module "gke_microservices" {
  count             = var.use_gke ? 1 : 0
  source            = "./modules/gke"

  gcp_region        = var.gcp_region
  microservice_name = "${var.microservice_name}-${var.environment}"
  container_image   = var.container_image
}

module "confluent_kafka" {
  count                = contains(["kafka", "both"], var.messaging_type) && !var.use_gke_kafka ? 1 : 0
  source               = "./modules/kafka"

  gcp_region           = var.gcp_region
  kafka_cluster_name   = "${var.kafka_cluster_name}-${var.environment}"
  confluent_api_key    = var.confluent_api_key
  confluent_api_secret = var.confluent_api_secret
}

module "gke_kafka" {
  count              = contains(["kafka", "both"], var.messaging_type) && var.use_gke_kafka ? 1 : 0
  source             = "./modules/gke-kafka"

  gcp_region         = var.gcp_region
  kafka_cluster_name = "${var.kafka_cluster_name}-${var.environment}"
}

module "rabbitmq" {
  count             = contains(["rabbitmq", "both"], var.messaging_type) ? 1 : 0
  source            = "./modules/gke-RabbitMQ"

  project_id        = var.project_id
  region            = var.gcp_region
  network           = module.networking.vpc_id
  subnetwork        = module.networking.private_subnet_id
  rabbitmq_user     = var.rabbitmq_user
  rabbitmq_password = var.rabbitmq_password
}

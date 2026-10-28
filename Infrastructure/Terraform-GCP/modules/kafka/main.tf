resource "confluent_environment" "kafka_environment" {
  display_name = "${var.kafka_cluster_name}-environment"
}

resource "confluent_kafka_cluster" "kafka" {
  display_name = var.kafka_cluster_name
  cloud        = "GCP"
  region       = var.gcp_region
  availability = var.availability

  environment {
    id = confluent_environment.kafka_environment.id
  }

  dedicated {
    cku = var.ckus
  }
}

resource "confluent_service_account" "kafka_sa" {
  display_name = "${var.kafka_cluster_name}-sa"
  description  = "Service account for Kafka cluster authentication"
}

resource "confluent_api_key" "kafka_api_key" {
  display_name = "${var.kafka_cluster_name}-api-key"

  owner {
    id          = confluent_service_account.kafka_sa.id
    api_version = confluent_service_account.kafka_sa.api_version
    kind        = confluent_service_account.kafka_sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.kafka.id
    api_version = confluent_kafka_cluster.kafka.api_version
    kind        = confluent_kafka_cluster.kafka.kind

    environment {
      id = confluent_environment.kafka_environment.id
    }
  }
}

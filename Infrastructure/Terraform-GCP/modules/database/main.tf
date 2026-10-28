resource "google_sql_database_instance" "microservice_db" {
  count            = var.database_type == "cloudsql" ? 1 : 0
  name             = var.db_instance_name
  region           = var.db_region
  database_version = var.db_version

  settings {
    tier              = var.db_tier
    availability_type = "REGIONAL"
    disk_autoresize   = true
    disk_size         = 20

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }
  }
}

resource "google_sql_user" "db_user" {
  count    = var.database_type == "cloudsql" ? 1 : 0
  name     = var.db_username
  instance = google_sql_database_instance.microservice_db[0].name
  password = var.db_password
}

resource "google_sql_database" "database" {
  count    = var.database_type == "cloudsql" ? 1 : 0
  name     = var.db_instance_name
  instance = google_sql_database_instance.microservice_db[0].name
}

resource "google_firestore_database" "microservice_firestore" {
  count       = var.database_type == "firestore" ? 1 : 0
  name        = "microservice-database"
  location_id = var.db_region
  type        = "FIRESTORE_NATIVE"
}

resource "mongodbatlas_project" "mongo_project" {
  count  = var.database_type == "mongo_atlas" ? 1 : 0
  name   = "microservice-mongo"
  org_id = var.mongodb_org_id
}

resource "mongodbatlas_cluster" "mongo_cluster" {
  count                       = var.database_type == "mongo_atlas" ? 1 : 0
  project_id                  = mongodbatlas_project.mongo_project[0].id
  name                        = "microservice-cluster"
  provider_name               = "GCP"
  backing_provider_name       = "GCP"
  provider_region_name        = var.db_region
  provider_instance_size_name = "M10"
  mongo_db_major_version      = "6.0"
}

resource "mongodbatlas_database_user" "mongo_user" {
  count              = var.database_type == "mongo_atlas" ? 1 : 0
  username           = var.db_username
  password           = var.db_password
  project_id          = mongodbatlas_project.mongo_project[0].id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "microservice-db"
  }
}

resource "google_compute_instance" "mongo_vm" {
  count        = var.database_type == "mongo_vm" ? 1 : 0
  name         = "mongodb-instance"
  machine_type = "n1-standard-1"
  zone         = "${var.db_region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update
    sudo apt install -y mongodb
    sudo systemctl start mongodb
    sudo systemctl enable mongodb
  EOT
}

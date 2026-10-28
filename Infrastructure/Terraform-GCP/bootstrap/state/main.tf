terraform {
  required_version = "~> 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

variable "project_id" {
  description = "GCP project that owns the Terraform state bucket."
  type        = string
}

variable "gcp_region" {
  description = "Location used for the state bucket (for example EU or europe-west1)."
  type        = string
  default     = "EU"
}

variable "environment" {
  description = "Environment label for the state bucket."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "terraform_sa_email" {
  description = "Optional service account to grant object administration to. Prefer narrowly scoped IAM and workload identity."
  type        = string
  default     = ""
}

provider "google" {
  project = var.project_id
}

resource "google_storage_bucket" "terraform_state" {
  name                        = "${var.project_id}-franz-terraform-state"
  project                     = var.project_id
  location                    = var.gcp_region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "terraform-state"
  }
}

resource "google_storage_bucket_iam_member" "terraform_state_access" {
  count  = var.terraform_sa_email == "" ? 0 : 1
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.terraform_sa_email}"
}

output "state_bucket_name" {
  description = "Use this bucket as the remote Terraform backend after bootstrap."
  value       = google_storage_bucket.terraform_state.name
}

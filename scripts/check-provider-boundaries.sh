#!/usr/bin/env bash
set -euo pipefail

# Resource types must remain inside their cloud-provider implementation.
# This catches stale modules that Terraform may still parse even when they
# are not instantiated by the root configuration.

check_no_foreign_resources() {
  local root="$1"
  local pattern="$2"
  local label="$3"

  if grep -R -n -E --include='*.tf' 'resource[[:space:]]+"' "$root" | grep -E "$pattern"; then
    echo "::error::Foreign provider resources found in $label ($root)."
    return 1
  fi
  echo "Provider boundary check passed: $label"
}

check_no_foreign_resources "Infrastructure/Terraform-AWS" 'google_|mongodbatlas_|azurerm_' "AWS Terraform"
check_no_foreign_resources "Infrastructure/Terraform-GCP" 'aws_|azurerm_' "GCP Terraform"

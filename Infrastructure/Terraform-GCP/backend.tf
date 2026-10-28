terraform {
  required_version = "~> 1.10"

  # Supply bucket and prefix with -backend-config during initialization.
  # The bucket must be bootstrapped separately before this backend is initialized.
  backend "gcs" {}
}

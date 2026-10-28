#######################################
# Global Variables
#######################################

variable "microservice_name" {
  description = "Name of the microservice (used for tagging and naming resources)"
  type        = string
}

variable "database_type" {
  description = "Database type: postgres, mysql, mariadb, oracle, sqlserver, or dynamodb"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for RDS instances"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "Instance class for RDS (e.g., db.t3.micro, db.t3.medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_version" {
  description = "Database version for RDS instances"
  type        = string
}

variable "db_name" {
  description = "Database name for RDS"
  type        = string
}

variable "db_username" {
  description = "Database username for RDS"
  type        = string
}

variable "db_password" {
  description = "Database password for RDS"
  type        = string
  sensitive   = true
}

variable "db_public_access" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "Base name for the DynamoDB table"
  type        = string
  default     = "microservice-table"
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment used for lifecycle safeguards"
  type        = string
  default     = "dev"
}

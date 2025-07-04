# Network Configuration

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. arc"
}

variable "subnet_names" {
  type        = list(string)
  description = "List of subnet names to lookup"
  default     = ["arc-poc-private-subnet-private-us-east-1a", "arc-poc-private-subnet-private-us-east-1b"]
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC to add the resources"
  default     = "arc-poc-vpc"
}

# IAM Configuration
variable "execution_role_arn" {
  description = "Default execution role ARN for SageMaker Studio"
  type        = string
}

variable "team_lead_role_arn" {
  description = "IAM role ARN for team lead user profile"
  type        = string
}

variable "senior_ds_role_arn" {
  description = "IAM role ARN for senior data scientist user profile"
  type        = string
}

variable "junior_ds_role_arn" {
  description = "IAM role ARN for junior data scientist user profile"
  type        = string
}

variable "ml_engineer_role_arn" {
  description = "IAM role ARN for ML engineer user profile"
  type        = string
}

variable "data_analyst_role_arn" {
  description = "IAM role ARN for data analyst user profile"
  type        = string
}

variable "pipeline_execution_role_arn" {
  description = "IAM role ARN for pipeline execution"
  type        = string
}

variable "create_execution_role" {
  description = "Whether to create a default execution role"
  type        = bool
  default     = false
}

# Storage Configuration
variable "shared_s3_path" {
  description = "S3 path for shared notebook outputs"
  type        = string
}

variable "input_data_s3_uri" {
  description = "S3 URI for input data in shared pipeline"
  type        = string
}

variable "output_data_s3_path" {
  description = "S3 path for pipeline output data"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# Environment Configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

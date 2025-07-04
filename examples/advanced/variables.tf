variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
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

variable "execution_role_arn" {
  description = "ARN of the IAM role for SageMaker execution"
  type        = string
}

variable "s3_output_path" {
  description = "S3 path for notebook outputs"
  type        = string
  default     = "s3://my-sagemaker-bucket/notebook-outputs/"
}

variable "training_data_s3_uri" {
  description = "S3 URI for training data"
  type        = string
  default     = "s3://my-sagemaker-bucket/training-data/"
}

variable "model_output_s3_path" {
  description = "S3 path for model outputs"
  type        = string
  default     = "s3://my-sagemaker-bucket/model-outputs/"
}

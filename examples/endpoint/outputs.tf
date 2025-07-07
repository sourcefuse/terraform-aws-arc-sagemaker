output "model_name" {
  description = "Name of the SageMaker model"
  value       = module.sagemaker_model.sagemaker_model_name
}

output "model_arn" {
  description = "ARN of the SageMaker model"
  value       = module.sagemaker_model.sagemaker_model_arn
}

output "endpoint_config_arn" {
  description = "ARN of the SageMaker endpoint configuration"
  value       = module.sagemaker_model.sagemaker_endpoint_config_arn
}

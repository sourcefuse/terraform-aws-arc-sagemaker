output "model_arn" {
  value       = var.create_model ? aws_sagemaker_model.this[0].arn : null
  description = "The ARN of the created SageMaker model"
}

output "model_name" {
  value       = var.create_model ? aws_sagemaker_model.this[0].name : null
  description = "The name of the created SageMaker model"
}


############################################################
############################################################

output "arn" {
  description = "The ARN assigned by AWS to this endpoint configuration."
  value       = var.create_endpoint_config ? aws_sagemaker_endpoint_configuration.this[0].arn : null
}

#############################################################

output "sagemaker_endpoint_arn" {
  description = "ARN of the SageMaker endpoint"
  value       = var.create_endpoint ? aws_sagemaker_endpoint.this[0].arn : null
}

output "sagemaker_endpoint_name" {
  description = "Name of the SageMaker endpoint"
  value       = var.create_endpoint ? aws_sagemaker_endpoint.this[0].name : null
}

output "sagemaker_endpoint_tags_all" {
  description = "All tags associated with the SageMaker endpoint"
  value       = var.create_endpoint ? aws_sagemaker_endpoint.this[0].tags_all : null
}

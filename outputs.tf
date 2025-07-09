output "sagemaker_domain_id" {
  description = "ID of the SageMaker domain"
  value       = length(aws_sagemaker_domain.this) > 0 ? aws_sagemaker_domain.this[0].id : null
}

output "sagemaker_domain_arn" {
  description = "ARN of the SageMaker domain"
  value       = length(aws_sagemaker_domain.this) > 0 ? aws_sagemaker_domain.this[0].arn : null
}

output "sagemaker_domain_url" {
  description = "URL to access the SageMaker Studio"
  value       = length(aws_sagemaker_domain.this) > 0 ? aws_sagemaker_domain.this[0].url : null
}

output "sagemaker_user_profile_names" {
  description = "List of SageMaker user profile names"
  value       = [for up in aws_sagemaker_user_profile.this : up.user_profile_name]
}

output "sagemaker_user_profiles" {
  description = "Map of SageMaker user profiles with their ARNs"
  value = {
    for up_key, up in aws_sagemaker_user_profile.this :
    up_key => {
      id                = up.id
      arn               = up.arn
      user_profile_name = up.user_profile_name
    }
  }
}

output "sagemaker_pipeline_arns" {
  description = "List of SageMaker pipeline ARNs"
  value       = [for p in aws_sagemaker_pipeline.this : p.arn]
}

output "sagemaker_pipeline_names" {
  description = "List of SageMaker pipeline names"
  value       = [for p in aws_sagemaker_pipeline.this : p.pipeline_name]
}

output "sagemaker_model_name" {
  description = "Name of the SageMaker model"
  value       = try(aws_sagemaker_model.this[0].name, null)
}

output "sagemaker_model_arn" {
  description = "ARN of the SageMaker model"
  value       = try(aws_sagemaker_model.this[0].arn, null)
}

output "sagemaker_endpoint_config_name" {
  description = "Name of the SageMaker endpoint configuration"
  value       = try(aws_sagemaker_endpoint_configuration.this[0].name, null)
}

output "sagemaker_endpoint_config_arn" {
  description = "ARN of the SageMaker endpoint configuration"
  value       = try(aws_sagemaker_endpoint_configuration.this[0].arn, null)
}
output "sagemaker_endpoint_name" {
  description = "Name of the SageMaker endpoint"
  value       = try(aws_sagemaker_endpoint.this[0].name, null)
}

output "sagemaker_endpoint_arn" {
  description = "ARN of the SageMaker endpoint"
  value       = try(aws_sagemaker_endpoint.this[0].arn, null)
}

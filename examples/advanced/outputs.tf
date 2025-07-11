output "domain_url" {
  description = "URL to access SageMaker Studio"
  value       = module.sagemaker_studio_basic.domain_url
}

output "domain_id" {
  description = "SageMaker Domain ID"
  value       = module.sagemaker_studio_basic.domain_id
}

output "user_profile_arn" {
  description = "ARN of the created user profile"
  value       = module.sagemaker_studio_basic.user_profiles
}

output "pipeline_arn" {
  description = "ARN of the created pipeline"
  value       = module.sagemaker_studio_basic.pipeline_arns
}

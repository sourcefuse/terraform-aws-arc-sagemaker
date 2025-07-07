output "domain_url" {
  description = "URL to access SageMaker Studio"
  value       = module.sagemaker_studio_multi_user.sagemaker_domain_url
}

output "domain_id" {
  description = "SageMaker Domain ID"
  value       = module.sagemaker_studio_multi_user.sagemaker_domain_id
}

output "user_profiles" {
  description = "Map of user profile names to their ARNs"
  value       = module.sagemaker_studio_multi_user.sagemaker_user_profiles
}

output "pipeline_arns" {
  description = "Map of pipeline names to their ARNs"
  value       = module.sagemaker_studio_multi_user.sagemaker_pipeline_arns
}

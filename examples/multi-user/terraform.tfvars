# Network Configuration
region      = "us-east-1"
environment = "develop"
namespace   = "arc"

# IAM Roles - Using placeholder ARNs (will be created by the module)
execution_role_arn          = "arn:aws:iam::884360309640:role/test-sagem"
team_lead_role_arn          = "arn:aws:iam::884360309640:role/SageMakerTeamLeadRole"
senior_ds_role_arn          = "arn:aws:iam::884360309640:role/SageMakerSeniorDSRole"
junior_ds_role_arn          = "arn:aws:iam::884360309640:role/SageMakerJuniorDSRole"
ml_engineer_role_arn        = "arn:aws:iam::884360309640:role/SageMakerMLEngineerRole"
data_analyst_role_arn       = "arn:aws:iam::884360309640:role/SageMakerDataAnalystRole"
pipeline_execution_role_arn = "arn:aws:iam::884360309640:role/SageMakerPipelineRole"

# Storage Configuration - Using existing SageMaker bucket
shared_s3_path      = "s3://amazon-sagemaker-884360309640-us-east-1-975720f49e0b/shared-outputs"
input_data_s3_uri   = "s3://amazon-sagemaker-884360309640-us-east-1-975720f49e0b/input-data/"
output_data_s3_path = "s3://amazon-sagemaker-884360309640-us-east-1-975720f49e0b/pipeline-outputs/"


# Create execution role since we don't have existing ones
create_execution_role = true

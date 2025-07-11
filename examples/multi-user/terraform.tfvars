# Network Configuration
region      = "us-east-1"
environment = "develop"
namespace   = "arc"

security_group_name = "arc-sagemaker-sg"
security_group_data = {
  create      = true
  description = "Security Group for sagemaker"
  ingress_rules = [
    {
      description = "Allow VPC traffic"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      ip_protocol = "tcp"
      to_port     = 443
    },
    {
      description = "Allow traffic from self"
      self        = true
      from_port   = 80
      ip_protocol = "tcp"
      to_port     = 80
    },
  ]
  egress_rules = [
    {
      description = "Allow all outbound traffic"
      cidr_block  = "0.0.0.0/0"
      from_port   = -1
      ip_protocol = "-1"
      to_port     = -1
    }
  ]
}

# Storage Configuration - Using existing SageMaker bucket
shared_s3_path      = "s3://amazon-sagemaker-884360309640-us-east-1-975720f49e0b/shared-outputs"
input_data_s3_uri   = "s3://amazon-sagemaker-884360309640-us-east-1-975720f49e0b/input-data/"
output_data_s3_path = "s3://amazon-sagemaker-884360309640-us-east-1-975720f49e0b/pipeline-outputs/"


# Create execution role since we don't have existing ones
create_execution_role = true


# This Terraform configuration creates the following AWS services:
# SageMaker Domain
# sageMaker User Profile
# sagemaker_pipeline
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.6"

  environment = terraform.workspace
  project     = "terraform-aws-arc-sagemaker"

  extra_tags = {
    Example = "True"
  }
}
module "sagemaker_studio_basic" {
  source = "../../"

  # Domain Configuration
  create_domain       = true
  create_pipeline     = true
  create_user_profile = true
  domain_name         = "basic-ml-domain"
  auth_mode           = "IAM"

  # Network Configuration
  vpc_id                 = data.aws_vpc.default.id
  subnet_ids             = [data.aws_subnets.private.ids[0]]
  create_security_groups = true

  # Default User Settings
  default_user_settings = {
    execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

    # Basic JupyterLab configuration
    jupyter_lab_app_settings = {
      default_resource_spec = {
        instance_type = "ml.t3.medium"
      }

      app_lifecycle_management = {
        idle_settings = {
          lifecycle_management    = "ENABLED"
          idle_timeout_in_minutes = 60
        }
      }
    }

    # Basic sharing settings
    sharing_settings = {
      notebook_output_option = "Allowed"
      s3_output_path         = var.s3_output_path
    }
  }

  # Single User Profile with proper user_settings
  user_profiles = [
    {
      name               = "data-scientist"
      execution_role_arn = aws_iam_role.sagemaker_execution_role.arn
      user_settings = {
        execution_role_arn = aws_iam_role.sagemaker_execution_role.arn
        jupyter_lab_app_settings = {
          default_resource_spec = {
            instance_type = "ml.t3.medium"
          }
        }
      }
    }
  ]

  # Basic Pipeline with fixed display name
  pipelines = [
    {
      name         = "basic-training-pipeline"
      display_name = "Basic-Training-Pipeline"
      description  = "A simple training pipeline for getting started"
      definition = jsonencode({
        Version = "2020-12-01"
        Steps = [
          {
            Name = "TrainingStep"
            Type = "Training"
            Arguments = {
              AlgorithmSpecification = {
                TrainingImage     = "382416733822.dkr.ecr.us-east-1.amazonaws.com/xgboost:latest"
                TrainingInputMode = "File"
              }
              InputDataConfig = [
                {
                  ChannelName = "training"
                  DataSource = {
                    S3DataSource = {
                      S3DataType = "S3Prefix"
                      S3Uri      = var.training_data_s3_uri
                    }
                  }
                  ContentType = "text/csv"
                }
              ]
              OutputDataConfig = {
                S3OutputPath = var.model_output_s3_path
              }
              ResourceConfig = {
                InstanceType   = "ml.m5.large"
                InstanceCount  = 1
                VolumeSizeInGB = 30
              }
              StoppingCondition = {
                MaxRuntimeInSeconds = 3600
              }
            }
          }
        ]
      })
    }
  ]

  # Create IAM role
  create_execution_role = true
  execution_role_name   = "SageMakerBasicExecutionRole"
  create_pipeline_role  = true

  tags = module.tags.tags
}

################## iam ####################

resource "aws_iam_role" "sagemaker_execution_role" {
  name = "multi-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

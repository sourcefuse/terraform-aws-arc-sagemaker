################################################################################
## defaults
################################################################################
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

module "sagemaker_studio_multi_user" {
  source = "../../"

  # Domain Configuration

  create_domain                 = true
  create_pipeline               = true
  create_user_profile           = true
  domain_name                   = "multi-user-ml-domain"
  auth_mode                     = "IAM"
  app_network_access_type       = "VpcOnly"
  app_security_group_management = "Service"

  # Network Configuration
  vpc_id                 = data.aws_vpc.default.id
  subnet_ids             = [data.aws_subnets.private.ids[0]]
  security_group_data    = var.security_group_data
  security_group_name    = var.security_group_name
  create_security_groups = true

  # Default User Settings - Balanced configuration
  default_user_settings = {
    execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

    # Standard JupyterLab Settings
    jupyter_lab_app_settings = {
      default_resource_spec = {
        instance_type = "ml.m5.large"
      }

      app_lifecycle_management = {
        idle_settings = {
          lifecycle_management        = "ENABLED"
          idle_timeout_in_minutes     = 120
          max_idle_timeout_in_minutes = 480
          min_idle_timeout_in_minutes = 60
        }
      }

      code_repositories = [
        {
          repository_url = "https://github.com/aws/amazon-sagemaker-examples.git"
        }
      ]
    }

    # Code Editor Settings
    code_editor_app_settings = {
      default_resource_spec = {
        instance_type = "ml.m5.large"
      }

      app_lifecycle_management = {
        idle_settings = {
          lifecycle_management        = "ENABLED"
          idle_timeout_in_minutes     = 120
          max_idle_timeout_in_minutes = 480
          min_idle_timeout_in_minutes = 60
        }
      }
    }

    # Sharing Settings
    sharing_settings = {
      notebook_output_option = "Allowed"
      s3_output_path         = var.shared_s3_path
      s3_kms_key_id          = var.kms_key_id
    }

    # Storage Settings
    space_storage_settings = {
      default_ebs_storage_settings = {
        default_ebs_volume_size_in_gb = 20
        maximum_ebs_volume_size_in_gb = 100
      }
    }
  }

  # Multiple User Profiles for Different Roles
  user_profiles = [
    # Data Science Team Lead
    {
      name               = "ds-team-lead"
      execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

      user_settings = {
        jupyter_lab_app_settings = {
          default_resource_spec = {
            instance_type = "ml.m5.xlarge"
          }
        }

        sharing_settings = {
          notebook_output_option = "Allowed"
          s3_output_path         = "${var.shared_s3_path}/team-lead/"
          s3_kms_key_id          = var.kms_key_id
        }
      }
    },

    # Senior Data Scientist
    {
      name               = "senior-data-scientist"
      execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

      user_settings = {
        jupyter_lab_app_settings = {
          default_resource_spec = {
            instance_type = "ml.m5.large"
          }
        }

        sharing_settings = {
          notebook_output_option = "Allowed"
          s3_output_path         = "${var.shared_s3_path}/senior-ds/"
          s3_kms_key_id          = var.kms_key_id
        }
      }
    },

    # Junior Data Scientist
    {
      name               = "junior-data-scientist"
      execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

      user_settings = {
        jupyter_lab_app_settings = {
          default_resource_spec = {
            instance_type = "ml.t3.large"
          }
        }

        sharing_settings = {
          notebook_output_option = "Allowed"
          s3_output_path         = "${var.shared_s3_path}/junior-ds/"
          s3_kms_key_id          = var.kms_key_id
        }

        studio_web_portal_settings = {
          hidden_instance_types = ["ml.p3.2xlarge", "ml.p3.8xlarge", "ml.p3.16xlarge"]
        }
      }
    },

    # ML Engineer
    {
      name               = "ml-engineer"
      execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

      user_settings = {
        jupyter_lab_app_settings = {
          default_resource_spec = {
            instance_type = "ml.m5.xlarge"
          }
        }

        code_editor_app_settings = {
          default_resource_spec = {
            instance_type = "ml.m5.xlarge"
          }
        }

        sharing_settings = {
          notebook_output_option = "Allowed"
          s3_output_path         = "${var.shared_s3_path}/ml-engineer/"
          s3_kms_key_id          = var.kms_key_id
        }
      }
    },

    # Data Analyst
    {
      name               = "data-analyst"
      execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

      user_settings = {
        jupyter_lab_app_settings = {
          default_resource_spec = {
            instance_type = "ml.t3.large"
          }
        }

        sharing_settings = {
          notebook_output_option = "Allowed"
          s3_output_path         = "${var.shared_s3_path}/data-analyst/"
          s3_kms_key_id          = var.kms_key_id
        }

        studio_web_portal_settings = {
          hidden_app_types      = ["TensorBoard"]
          hidden_instance_types = ["ml.p3.2xlarge", "ml.p3.8xlarge", "ml.p3.16xlarge", "ml.p4d.24xlarge"]
        }
      }
    }
  ]

  # Basic Pipeline for Shared Use
  pipelines = [
    {
      name         = "shared-data-pipeline"
      display_name = "Shared-Data-Processing-Pipeline"
      description  = "Common data processing pipeline for all users"

      definition = jsonencode({
        Version = "2020-12-01"
        Parameters = [
          {
            Name         = "InputDataPath"
            Type         = "String"
            DefaultValue = var.input_data_s3_uri
          },
          {
            Name         = "OutputDataPath"
            Type         = "String"
            DefaultValue = var.output_data_s3_path
          }
        ]
        Steps = [
          {
            Name = "DataProcessing"
            Type = "Processing"
            Arguments = {
              ProcessingResources = {
                ClusterConfig = {
                  InstanceType   = "ml.m5.large"
                  InstanceCount  = 1
                  VolumeSizeInGB = 30
                }
              }
              AppSpecification = {
                ImageUri = "382416733822.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:0.23-1-cpu-py3"
              }
            }
          }
        ]
      })

      parallelism_configuration = {
        max_parallel_execution_steps = 2
      }
    }
  ]

  # IAM Configuration
  create_execution_role = var.create_execution_role
  execution_role_name   = "SageMakerMultiUserExecutionRole"
  create_pipeline_role  = true

  additional_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

  # Tags for cost tracking and management
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

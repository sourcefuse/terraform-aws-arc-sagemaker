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

module "sagemaker_model" {
  source = "../.."

  name                   = "terraform-arc"
  create_domain          = false
  create_endpoint_config = true
  create_model           = true
  create_pipeline        = false
  create_user_profile    = false
  create_security_groups = false

  primary_container = {
    image          = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1-cpu-py3"
    model_data_url = "s3://your-sagemaker-model-bucket-21-05-25/model/model.tar.gz"
    environment    = {}
  }

  production_variants = [
    {
      variant_name           = "AllTraffic"
      initial_instance_count = 1
      instance_type          = "ml.m5.large"
      initial_variant_weight = 1.0
    }
  ]
  tags = module.tags.tags
}

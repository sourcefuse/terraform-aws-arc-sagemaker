variable "name" {
  type        = string
  description = "The name of the SageMaker model."
  default     = "terraform-sg"
}

variable "primary_container" {
  type = object({
    image              = string
    mode               = optional(string)
    model_data_url     = optional(string)
    model_package_name = optional(string)
    container_hostname = optional(string)
    environment        = optional(map(string))
    image_config = optional(object({
      repository_access_mode = string
      repository_auth_config = optional(object({
        repository_credentials_provider_arn = string
      }))
    }))
    inference_specification_name = optional(string)
    multi_model_config = optional(object({
      model_cache_setting = string
    }))
    model_data_source = optional(object({
      s3_data_source = object({
        compression_type = string
        s3_data_type     = string
        s3_uri           = string
        model_access_config = optional(object({
          accept_eula = bool
        }))
      })
    }))
  })
  #   default     = null
  default = {
    image          = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1-cpu-py3"
    model_data_url = "s3://your-sagemaker-model-bucket-21-05-25/model/model.tar.gz"
    environment    = {}
  }
  description = "Primary container block"
}

variable "container" {
  type        = list(any)
  default     = null
  description = "List of containers for inference pipeline (alternative to primary_container)"
}

variable "inference_execution_config" {
  type = object({
    mode = string
  })
  default     = null
  description = "Multi-container execution configuration"
}

variable "enable_network_isolation" {
  type        = bool
  default     = null
  description = "Isolate the model container from external network"
}

variable "create_endpoint" {
  description = "Whether to create the SageMaker endpoint"
  type        = bool
  default     = false
}

variable "vpc_config" {
  type = object({
    security_group_ids = list(string)
    subnets            = list(string)
  })
  default     = null
  description = "VPC configuration for the model"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to assign to the SageMaker model"
}


##################################################
# SageManker - Configuration
##################################################


variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix for the endpoint configuration name. Conflicts with name."
  default     = null
}

variable "kms_key_arn" {
  type        = string
  description = "(Optional) ARN of the KMS key to encrypt storage volume data."
  default     = null
}

variable "production_variants" {
  description = "(Required) List of production variant configurations."
  type = list(object({
    variant_name                                      = optional(string)
    model_name                                        = optional(string)
    initial_instance_count                            = optional(number)
    instance_type                                     = optional(string)
    accelerator_type                                  = optional(string)
    container_startup_health_check_timeout_in_seconds = optional(number)
    core_dump_config = optional(object({
      destination_s3_uri = string
      kms_key_id         = string
    }))
    enable_ssm_access                      = optional(bool)
    inference_ami_version                  = optional(string)
    initial_variant_weight                 = optional(number)
    model_data_download_timeout_in_seconds = optional(number)
    routing_config = optional(object({
      routing_strategy = string
    }))
    serverless_config = optional(object({
      max_concurrency         = number
      memory_size_in_mb       = number
      provisioned_concurrency = optional(number)
    }))
    managed_instance_scaling = optional(object({
      status             = optional(string)
      min_instance_count = optional(number)
      max_instance_count = optional(number)
    }))
    volume_size_in_gb = optional(number)
  }))
  default = [
    {
      variant_name = "AllTraffic"
      #   model_name             = "default-model"
      initial_instance_count = 1
      instance_type          = "ml.m5.large"
      initial_variant_weight = 1.0
    }
  ]
}

variable "shadow_production_variants" {
  description = "(Optional) List of shadow production variant configurations."
  type = list(object({
    variant_name           = optional(string)
    model_name             = string
    initial_instance_count = optional(number)
    instance_type          = optional(string)
    initial_variant_weight = optional(number)
  }))
  default = []
}

variable "data_capture_config" {
  description = "(Optional) Configuration for capturing input/output data."
  type = object({
    initial_sampling_percentage = number
    destination_s3_uri          = string
    kms_key_id                  = optional(string)
    enable_capture              = optional(bool)
    capture_options = list(object({
      capture_mode = string
    }))
    capture_content_type_header = optional(object({
      csv_content_types  = optional(list(string))
      json_content_types = optional(list(string))
    }))
  })
  default = null
}

variable "async_inference_config" {
  description = "(Optional) Configuration for asynchronous inference."
  type = object({
    output_config = object({
      s3_output_path  = string
      s3_failure_path = optional(string)
      kms_key_id      = optional(string)
      notification_config = optional(object({
        include_inference_response_in = optional(string)
        error_topic                   = optional(string)
        success_topic                 = optional(string)
      }))
    })
    client_config = optional(object({
      max_concurrent_invocations_per_instance = optional(number)
    }))
  })
  default = null
}

##########################################
##########################################

# variable "endpoint_config_name" {
#   description = "The name of the endpoint configuration to use"
#   type        = string
# }

variable "deployment_config" {
  description = "Deployment configuration block"
  type = object({
    blue_green_update_policy = optional(object({
      traffic_routing_configuration = object({
        type                     = string
        wait_interval_in_seconds = number
        canary_size = optional(object({
          type  = string
          value = number
        }))
        linear_step_size = optional(object({
          type  = string
          value = number
        }))
      })
      maximum_execution_timeout_in_seconds = optional(number)
      termination_wait_in_seconds          = optional(number)
    }))
    auto_rollback_configuration = optional(object({
      alarms = list(object({
        alarm_name = string
      }))
    }))
    rolling_update_policy = optional(object({
      wait_interval_in_seconds             = number
      maximum_execution_timeout_in_seconds = optional(number)
      maximum_batch_size = object({
        type  = string
        value = number
      })
      rollback_maximum_batch_size = optional(object({
        type  = string
        value = number
      }))
    }))
  })
  default = null
}

#########################################################################################################################################################

# Domain Configuration Variables
variable "domain_name" {
  description = "The name of the SageMaker domain"
  type        = string
  default     = "arc-sagemaker-domain"
}

variable "auth_mode" {
  description = "The mode of authentication that members use to access the domain. Valid values are IAM and SSO"
  type        = string
  default     = "IAM"
  validation {
    condition     = contains(["IAM", "SSO"], var.auth_mode)
    error_message = "Auth mode must be either 'IAM' or 'SSO'."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC that Studio uses for communication"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "The VPC subnets that Studio uses for communication"
  type        = list(string)
  default     = [""]
}

variable "app_network_access_type" {
  description = "Specifies the VPC used for non-EFS traffic. Valid values are PublicInternetOnly and VpcOnly"
  type        = string
  default     = "PublicInternetOnly"
  validation {
    condition     = contains(["PublicInternetOnly", "VpcOnly"], var.app_network_access_type)
    error_message = "App network access type must be either 'PublicInternetOnly' or 'VpcOnly'."
  }
}

variable "app_security_group_management" {
  description = "The entity that creates and manages the required security groups for inter-app communication in VPCOnly mode. Valid values are Service and Customer"
  type        = string
  default     = "Service"
  validation {
    condition     = contains(["Service", "Customer"], var.app_security_group_management)
    error_message = "App security group management must be either 'Service' or 'Customer'."
  }
}

variable "kms_key_id" {
  description = "The AWS KMS customer managed CMK used to encrypt the EFS volume attached to the domain"
  type        = string
  default     = null
}

variable "tag_propagation" {
  description = "Indicates whether custom tag propagation is supported for the domain. Valid values are ENABLED and DISABLED"
  type        = string
  default     = "DISABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.tag_propagation)
    error_message = "Tag propagation must be either 'ENABLED' or 'DISABLED'."
  }
}

# Default User Settings
variable "default_user_settings" {
  description = "The default user settings for the domain"
  type = object({
    execution_role_arn  = string
    auto_mount_home_efs = optional(string, "Enabled")
    default_landing_uri = optional(string)
    studio_web_portal   = optional(string, "ENABLED")

    jupyter_lab_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))

      app_lifecycle_management = optional(object({
        idle_settings = optional(object({
          lifecycle_management        = optional(string, "ENABLED")
          idle_timeout_in_minutes     = optional(number, 60)
          max_idle_timeout_in_minutes = optional(number, 480)
          min_idle_timeout_in_minutes = optional(number, 60)
        }))
      }))

      custom_images = optional(list(object({
        app_image_config_name = string
        image_name            = string
        image_version_number  = optional(number)
      })))

      code_repositories = optional(list(object({
        repository_url = string
      })))

      lifecycle_config_arns         = optional(list(string))
      built_in_lifecycle_config_arn = optional(string)

      emr_settings = optional(object({
        assumable_role_arns = optional(list(string))
        execution_role_arns = optional(list(string))
      }))
    }))

    code_editor_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))

      app_lifecycle_management = optional(object({
        idle_settings = optional(object({
          lifecycle_management        = optional(string, "ENABLED")
          idle_timeout_in_minutes     = optional(number, 60)
          max_idle_timeout_in_minutes = optional(number, 480)
          min_idle_timeout_in_minutes = optional(number, 60)
        }))
      }))

      custom_images = optional(list(object({
        app_image_config_name = string
        image_name            = string
        image_version_number  = optional(number)
      })))

      lifecycle_config_arns         = optional(list(string))
      built_in_lifecycle_config_arn = optional(string)
    }))

    jupyter_server_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))

      code_repositories = optional(list(object({
        repository_url = string
      })))

      lifecycle_config_arns = optional(list(string))
    }))

    kernel_gateway_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))

      custom_images = optional(list(object({
        app_image_config_name = string
        image_name            = string
        image_version_number  = optional(number)
      })))

      lifecycle_config_arns = optional(list(string))
    }))

    canvas_app_settings = optional(object({
      time_series_forecasting_settings = optional(object({
        status                   = optional(string, "DISABLED")
        amazon_forecast_role_arn = optional(string)
      }))

      model_register_settings = optional(object({
        status                                = optional(string, "DISABLED")
        cross_account_model_register_role_arn = optional(string)
      }))

      workspace_settings = optional(object({
        s3_artifact_path = optional(string)
        s3_kms_key_id    = optional(string)
      }))

      direct_deploy_settings = optional(object({
        status = optional(string, "DISABLED")
      }))

      kendra_settings = optional(object({
        status = optional(string, "DISABLED")
      }))

      identity_provider_oauth_settings = optional(list(object({
        data_source_name = optional(string)
        secret_arn       = optional(string)
        status           = optional(string, "DISABLED")
      })))

      emr_serverless_settings = optional(object({
        execution_role_arn = optional(string)
        status             = optional(string, "DISABLED")
      }))
    }))

    tensor_board_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))
    }))

    r_session_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))

      custom_images = optional(list(object({
        app_image_config_name = string
        image_name            = string
        image_version_number  = optional(number)
      })))
    }))

    r_studio_server_pro_app_settings = optional(object({
      access_status = optional(string, "DISABLED")
      user_group    = optional(string, "R_STUDIO_USER")
    }))

    sharing_settings = optional(object({
      notebook_output_option = optional(string, "Disabled")
      s3_kms_key_id          = optional(string)
      s3_output_path         = optional(string)
    }))

    space_storage_settings = optional(object({
      default_ebs_storage_settings = optional(object({
        default_ebs_volume_size_in_gb = number
        maximum_ebs_volume_size_in_gb = number
      }))
    }))

    custom_file_system_config = optional(object({
      efs_file_system_config = optional(object({
        file_system_id   = string
        file_system_path = string
      }))
    }))

    custom_posix_user_config = optional(object({
      gid = optional(number)
      uid = optional(number)
    }))

    studio_web_portal_settings = optional(object({
      hidden_app_types      = optional(list(string))
      hidden_instance_types = optional(list(string))
      hidden_ml_tools       = optional(list(string))
    }))
  })
  default = null
}

# Default Space Settings
variable "default_space_settings" {
  description = "The default space settings for the domain"
  type = object({
    execution_role_arn = string
    security_groups    = optional(list(string))

    jupyter_server_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))
    }))

    kernel_gateway_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))
    }))

    jupyter_lab_app_settings = optional(object({
      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))
    }))

    space_storage_settings = optional(object({
      default_ebs_storage_settings = optional(object({
        default_ebs_volume_size_in_gb = number
        maximum_ebs_volume_size_in_gb = number
      }))
    }))

    custom_file_system_config = optional(object({
      efs_file_system_config = optional(object({
        file_system_id   = string
        file_system_path = string
      }))
    }))

    custom_posix_user_config = optional(object({
      gid = optional(number)
      uid = optional(number)
    }))
  })
  default = null
}

# Domain Settings
variable "domain_settings" {
  description = "The domain settings"
  type = object({
    execution_role_identity_config = optional(string, "USER_PROFILE_NAME")
    security_group_ids             = optional(list(string))

    docker_settings = optional(object({
      enable_docker_access      = optional(string, "ENABLED")
      vpc_only_trusted_accounts = optional(list(string))
    }))

    r_studio_server_pro_domain_settings = optional(object({
      domain_execution_role_arn    = string
      r_studio_connect_url         = optional(string)
      r_studio_package_manager_url = optional(string)

      default_resource_spec = optional(object({
        instance_type                 = optional(string, "ml.t3.medium")
        lifecycle_config_arn          = optional(string)
        sagemaker_image_arn           = optional(string)
        sagemaker_image_version_arn   = optional(string)
        sagemaker_image_version_alias = optional(string)
      }))
    }))
  })
  default = null
}

# Retention Policy
variable "retention_policy" {
  description = "The retention policy for the domain"
  type = object({
    home_efs_file_system = optional(string, "Retain")
  })
  default = null
}

# User Profiles
variable "user_profiles" {
  description = "List of user profiles to create"
  type = list(object({
    name                           = string
    execution_role_arn             = optional(string)
    single_sign_on_user_identifier = optional(string)
    single_sign_on_user_value      = optional(string)
    tags                           = optional(map(string))

    user_settings = optional(object({
      auto_mount_home_efs = optional(string)
      default_landing_uri = optional(string)
      studio_web_portal   = optional(string)
      security_groups     = optional(list(string))

      jupyter_lab_app_settings = optional(object({
        default_resource_spec = optional(object({
          instance_type                 = optional(string)
          lifecycle_config_arn          = optional(string)
          sagemaker_image_arn           = optional(string)
          sagemaker_image_version_arn   = optional(string)
          sagemaker_image_version_alias = optional(string)
        }))

        app_lifecycle_management = optional(object({
          idle_settings = optional(object({
            lifecycle_management        = optional(string)
            idle_timeout_in_minutes     = optional(number)
            max_idle_timeout_in_minutes = optional(number)
            min_idle_timeout_in_minutes = optional(number)
          }))
        }))

        custom_images = optional(list(object({
          app_image_config_name = string
          image_name            = string
          image_version_number  = optional(number)
        })))

        code_repositories = optional(list(object({
          repository_url = string
        })))

        lifecycle_config_arns         = optional(list(string))
        built_in_lifecycle_config_arn = optional(string)

        emr_settings = optional(object({
          assumable_role_arns = optional(list(string))
          execution_role_arns = optional(list(string))
        }))
      }))

      code_editor_app_settings = optional(object({
        default_resource_spec = optional(object({
          instance_type                 = optional(string)
          lifecycle_config_arn          = optional(string)
          sagemaker_image_arn           = optional(string)
          sagemaker_image_version_arn   = optional(string)
          sagemaker_image_version_alias = optional(string)
        }))

        app_lifecycle_management = optional(object({
          idle_settings = optional(object({
            lifecycle_management        = optional(string)
            idle_timeout_in_minutes     = optional(number)
            max_idle_timeout_in_minutes = optional(number)
            min_idle_timeout_in_minutes = optional(number)
          }))
        }))

        custom_images = optional(list(object({
          app_image_config_name = string
          image_name            = string
          image_version_number  = optional(number)
        })))

        lifecycle_config_arns         = optional(list(string))
        built_in_lifecycle_config_arn = optional(string)
      }))

      jupyter_server_app_settings = optional(object({
        default_resource_spec = optional(object({
          instance_type                 = optional(string)
          lifecycle_config_arn          = optional(string)
          sagemaker_image_arn           = optional(string)
          sagemaker_image_version_arn   = optional(string)
          sagemaker_image_version_alias = optional(string)
        }))

        code_repositories = optional(list(object({
          repository_url = string
        })))

        lifecycle_config_arns = optional(list(string))
      }))

      kernel_gateway_app_settings = optional(object({
        default_resource_spec = optional(object({
          instance_type                 = optional(string)
          lifecycle_config_arn          = optional(string)
          sagemaker_image_arn           = optional(string)
          sagemaker_image_version_arn   = optional(string)
          sagemaker_image_version_alias = optional(string)
        }))

        custom_images = optional(list(object({
          app_image_config_name = string
          image_name            = string
          image_version_number  = optional(number)
        })))

        lifecycle_config_arns = optional(list(string))
      }))

      canvas_app_settings = optional(object({
        time_series_forecasting_settings = optional(object({
          status                   = optional(string)
          amazon_forecast_role_arn = optional(string)
        }))

        model_register_settings = optional(object({
          status                                = optional(string)
          cross_account_model_register_role_arn = optional(string)
        }))

        workspace_settings = optional(object({
          s3_artifact_path = optional(string)
          s3_kms_key_id    = optional(string)
        }))

        direct_deploy_settings = optional(object({
          status = optional(string)
        }))

        kendra_settings = optional(object({
          status = optional(string)
        }))

        identity_provider_oauth_settings = optional(list(object({
          data_source_name = optional(string)
          secret_arn       = optional(string)
          status           = optional(string)
        })))

        emr_serverless_settings = optional(object({
          execution_role_arn = optional(string)
          status             = optional(string)
        }))
      }))

      tensor_board_app_settings = optional(object({
        default_resource_spec = optional(object({
          instance_type                 = optional(string)
          lifecycle_config_arn          = optional(string)
          sagemaker_image_arn           = optional(string)
          sagemaker_image_version_arn   = optional(string)
          sagemaker_image_version_alias = optional(string)
        }))
      }))

      r_session_app_settings = optional(object({
        default_resource_spec = optional(object({
          instance_type                 = optional(string)
          lifecycle_config_arn          = optional(string)
          sagemaker_image_arn           = optional(string)
          sagemaker_image_version_arn   = optional(string)
          sagemaker_image_version_alias = optional(string)
        }))

        custom_images = optional(list(object({
          app_image_config_name = string
          image_name            = string
          image_version_number  = optional(number)
        })))
      }))

      r_studio_server_pro_app_settings = optional(object({
        access_status = optional(string)
        user_group    = optional(string)
      }))

      sharing_settings = optional(object({
        notebook_output_option = optional(string)
        s3_kms_key_id          = optional(string)
        s3_output_path         = optional(string)
      }))

      space_storage_settings = optional(object({
        default_ebs_storage_settings = optional(object({
          default_ebs_volume_size_in_gb = number
          maximum_ebs_volume_size_in_gb = number
        }))
      }))

      custom_file_system_config = optional(object({
        efs_file_system_config = optional(object({
          file_system_id   = string
          file_system_path = string
        }))
      }))

      custom_posix_user_config = optional(object({
        gid = optional(number)
        uid = optional(number)
      }))

      studio_web_portal_settings = optional(object({
        hidden_app_types      = optional(list(string))
        hidden_instance_types = optional(list(string))
        hidden_ml_tools       = optional(list(string))
      }))
    }))
  }))
  default = []
}

# Pipelines
variable "pipelines" {
  description = "List of SageMaker pipelines to create"
  type = list(object({
    name         = string
    display_name = string
    description  = optional(string)
    definition   = optional(string)
    role_arn     = optional(string)
    tags         = optional(map(string))

    pipeline_definition_s3_location = optional(object({
      bucket     = string
      object_key = string
      version_id = optional(string)
    }))

    parallelism_configuration = optional(object({
      max_parallel_execution_steps = number
    }))
  }))
  default = []
}

# IAM Configuration
variable "create_execution_role" {
  description = "Whether to create an execution role for SageMaker"
  type        = bool
  default     = false
}

variable "execution_role_name" {
  description = "Name of the execution role to create"
  type        = string
  default     = "SageMakerStudioExecutionRole"
}

variable "execution_role_path" {
  description = "Path for the execution role"
  type        = string
  default     = "/"
}

variable "create_pipeline_role" {
  description = "Whether to create a separate role for pipelines"
  type        = bool
  default     = false
}

variable "pipeline_role_name" {
  description = "Name of the pipeline role to create"
  type        = string
  default     = "SageMakerPipelineExecutionRole"
}

variable "pipeline_role_path" {
  description = "Path for the pipeline role"
  type        = string
  default     = "/"
}

variable "additional_iam_policies" {
  description = "List of additional IAM policy ARNs to attach to the execution role"
  type        = list(string)
  default     = []
}

# Security Group Configuration
variable "create_security_groups" {
  description = "Whether to create security groups for SageMaker Studio"
  type        = bool
  default     = true
}

variable "additional_security_group_ids" {
  description = "List of additional security group IDs to attach to the domain"
  type        = list(string)
  default     = []
}

variable "create_efs_security_group" {
  description = "Whether to create a security group for EFS"
  type        = bool
  default     = false
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for the SageMaker security group"
  type = list(object({
    description      = optional(string)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
  }))
  default = []
}

variable "security_group_egress_rules" {
  description = "List of egress rules for the SageMaker security group"
  type = list(object({
    description      = optional(string)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
  }))
  default = []
}

variable "create_user_profile" {
  description = "Whether to create the SageMaker user profile"
  type        = bool
  default     = true
}

variable "create_pipeline" {
  description = "Whether to create the SageMaker pipeline"
  type        = bool
  default     = true
}

variable "create_domain" {
  description = "Whether to create the SageMaker domain"
  type        = bool
  default     = true
}
variable "create_model" {
  description = "Whether to create the SageMaker model"
  type        = bool
  default     = false
}

variable "create_endpoint_config" {
  description = "Whether to create the SageMaker endpoint configuration"
  type        = bool
  default     = false
}

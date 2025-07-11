###################################################################################
# sagemaker model
###################################################################################
resource "aws_sagemaker_model" "this" {
  count              = var.create_model ? 1 : 0
  name               = var.name
  execution_role_arn = aws_iam_role.sagemaker_execution_role[0].arn
  tags               = var.tags

  dynamic "primary_container" {
    for_each = var.primary_container == null ? [] : [var.primary_container]
    content {
      image                        = primary_container.value.image
      mode                         = lookup(primary_container.value, "mode", null)
      model_data_url               = lookup(primary_container.value, "model_data_url", "null")
      model_package_name           = lookup(primary_container.value, "model_package_name", null)
      container_hostname           = lookup(primary_container.value, "container_hostname", null)
      environment                  = lookup(primary_container.value, "environment", null)
      inference_specification_name = lookup(primary_container.value, "inference_specification_name", null)

      dynamic "image_config" {
        for_each = lookup(primary_container.value, "image_config", null) == null ? [] : [primary_container.value.image_config]
        content {
          repository_access_mode = image_config.value.repository_access_mode

          dynamic "repository_auth_config" {
            for_each = lookup(image_config.value, "repository_auth_config", null) == null ? [] : [image_config.value.repository_auth_config]
            content {
              repository_credentials_provider_arn = repository_auth_config.value.repository_credentials_provider_arn
            }
          }
        }
      }

      dynamic "multi_model_config" {
        for_each = lookup(primary_container.value, "multi_model_config", null) == null ? [] : [primary_container.value.multi_model_config]
        content {
          model_cache_setting = multi_model_config.value.model_cache_setting
        }
      }

      dynamic "model_data_source" {
        for_each = lookup(primary_container.value, "model_data_source", null) == null ? [] : [primary_container.value.model_data_source]
        content {
          dynamic "s3_data_source" {
            for_each = model_data_source.value.s3_data_source == null ? [] : [model_data_source.value.s3_data_source]
            content {
              compression_type = s3_data_source.value.compression_type
              s3_data_type     = s3_data_source.value.s3_data_type
              s3_uri           = s3_data_source.value.s3_uri

              dynamic "model_access_config" {
                for_each = lookup(s3_data_source.value, "model_access_config", null) == null ? [] : [s3_data_source.value.model_access_config]
                content {
                  accept_eula = model_access_config.value.accept_eula
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "container" {
    for_each = var.container == null ? [] : var.container
    content {
      image          = container.value.image
      model_data_url = lookup(container.value, "model_data_url", null)
      environment    = lookup(container.value, "environment", null)
    }
  }

  dynamic "inference_execution_config" {
    for_each = var.inference_execution_config == null ? [] : [var.inference_execution_config]
    content {
      mode = inference_execution_config.value.mode
    }
  }

  enable_network_isolation = var.enable_network_isolation

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnets            = vpc_config.value.subnets
    }
  }
}


###################################################################################
# SageManker - Configuration
###################################################################################
resource "aws_sagemaker_endpoint_configuration" "this" {
  count       = var.create_endpoint_config ? 1 : 0
  name        = "${var.name}-endpoint-configuration"
  name_prefix = var.name_prefix
  kms_key_arn = var.kms_key_arn
  tags        = var.tags

  dynamic "production_variants" {
    for_each = var.production_variants
    content {
      variant_name                                      = lookup(production_variants.value, "variant_name", null)
      model_name                                        = coalesce(production_variants.value.model_name, aws_sagemaker_model.this[0].name)
      initial_instance_count                            = lookup(production_variants.value, "initial_instance_count", null)
      instance_type                                     = lookup(production_variants.value, "instance_type", null)
      accelerator_type                                  = lookup(production_variants.value, "accelerator_type", null)
      container_startup_health_check_timeout_in_seconds = lookup(production_variants.value, "container_startup_health_check_timeout_in_seconds", null)
      enable_ssm_access                                 = lookup(production_variants.value, "enable_ssm_access", null)
      inference_ami_version                             = lookup(production_variants.value, "inference_ami_version", null)
      initial_variant_weight                            = lookup(production_variants.value, "initial_variant_weight", null)
      model_data_download_timeout_in_seconds            = lookup(production_variants.value, "model_data_download_timeout_in_seconds", null)
      volume_size_in_gb                                 = lookup(production_variants.value, "volume_size_in_gb", null)

      dynamic "routing_config" {
        for_each = lookup(production_variants.value, "routing_config", null) != null ? [production_variants.value.routing_config] : []
        content {
          routing_strategy = routing_config.value.routing_strategy
        }
      }

      dynamic "serverless_config" {
        for_each = lookup(production_variants.value, "serverless_config", null) != null ? [production_variants.value.serverless_config] : []
        content {
          max_concurrency         = serverless_config.value.max_concurrency
          memory_size_in_mb       = serverless_config.value.memory_size_in_mb
          provisioned_concurrency = lookup(serverless_config.value, "provisioned_concurrency", null)
        }
      }

      dynamic "managed_instance_scaling" {
        for_each = lookup(production_variants.value, "managed_instance_scaling", null) != null ? [production_variants.value.managed_instance_scaling] : []
        content {
          status             = lookup(managed_instance_scaling.value, "status", null)
          min_instance_count = lookup(managed_instance_scaling.value, "min_instance_count", null)
          max_instance_count = lookup(managed_instance_scaling.value, "max_instance_count", null)
        }
      }

      dynamic "core_dump_config" {
        for_each = lookup(production_variants.value, "core_dump_config", null) != null ? [production_variants.value.core_dump_config] : []
        content {
          destination_s3_uri = core_dump_config.value.destination_s3_uri
          kms_key_id         = core_dump_config.value.kms_key_id
        }
      }
    }
  }

  dynamic "shadow_production_variants" {
    for_each = var.shadow_production_variants
    content {
      variant_name           = lookup(shadow_production_variants.value, "variant_name", null)
      model_name             = lookup(shadow_production_variants.value, "model_name", null)
      initial_instance_count = lookup(shadow_production_variants.value, "initial_instance_count", null)
      instance_type          = lookup(shadow_production_variants.value, "instance_type", null)
      initial_variant_weight = lookup(shadow_production_variants.value, "initial_variant_weight", null)
    }
  }

  dynamic "data_capture_config" {
    for_each = var.data_capture_config != null ? [var.data_capture_config] : []
    content {
      initial_sampling_percentage = data_capture_config.value.initial_sampling_percentage
      destination_s3_uri          = data_capture_config.value.destination_s3_uri
      kms_key_id                  = lookup(data_capture_config.value, "kms_key_id", null)
      enable_capture              = lookup(data_capture_config.value, "enable_capture", null)

      dynamic "capture_options" {
        for_each = data_capture_config.value.capture_options
        content {
          capture_mode = capture_options.value.capture_mode
        }
      }

      dynamic "capture_content_type_header" {
        for_each = lookup(data_capture_config.value, "capture_content_type_header", null) != null ? [data_capture_config.value.capture_content_type_header] : []
        content {
          csv_content_types  = lookup(capture_content_type_header.value, "csv_content_types", null)
          json_content_types = lookup(capture_content_type_header.value, "json_content_types", null)
        }
      }
    }
  }

  dynamic "async_inference_config" {
    for_each = var.async_inference_config != null ? [var.async_inference_config] : []
    content {
      dynamic "output_config" {
        for_each = [async_inference_config.value.output_config]
        content {
          s3_output_path  = output_config.value.s3_output_path
          s3_failure_path = lookup(output_config.value, "s3_failure_path", null)
          kms_key_id      = lookup(output_config.value, "kms_key_id", null)

          dynamic "notification_config" {
            for_each = lookup(output_config.value, "notification_config", null) != null ? [output_config.value.notification_config] : []
            content {
              include_inference_response_in = lookup(notification_config.value, "include_inference_response_in", null)
              error_topic                   = lookup(notification_config.value, "error_topic", null)
              success_topic                 = lookup(notification_config.value, "success_topic", null)
            }
          }
        }
      }

      dynamic "client_config" {
        for_each = lookup(async_inference_config.value, "client_config", null) != null ? [async_inference_config.value.client_config] : []
        content {
          max_concurrent_invocations_per_instance = lookup(client_config.value, "max_concurrent_invocations_per_instance", null)
        }
      }
    }
  }
}
###################################################################################
###################### sagemaker-endpoint #####################
###################################################################################
resource "aws_sagemaker_endpoint" "this" {
  count                = var.create_endpoint ? 1 : 0
  name                 = "${var.name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.this[0].name

  tags = var.tags

  dynamic "deployment_config" {
    for_each = var.deployment_config != null ? [1] : []
    content {
      dynamic "blue_green_update_policy" {
        for_each = lookup(var.deployment_config, "blue_green_update_policy", null) != null ? [1] : []
        content {
          dynamic "traffic_routing_configuration" {
            for_each = [var.deployment_config.blue_green_update_policy.traffic_routing_configuration]
            content {
              type                     = traffic_routing_configuration.value.type
              wait_interval_in_seconds = traffic_routing_configuration.value.wait_interval_in_seconds
              canary_size {
                type  = lookup(traffic_routing_configuration.value.canary_size, "type", null)
                value = lookup(traffic_routing_configuration.value.canary_size, "value", null)
              }
              linear_step_size {
                type  = lookup(traffic_routing_configuration.value.linear_step_size, "type", null)
                value = lookup(traffic_routing_configuration.value.linear_step_size, "value", null)
              }
            }
          }

          maximum_execution_timeout_in_seconds = lookup(var.deployment_config.blue_green_update_policy, "maximum_execution_timeout_in_seconds", null)
          termination_wait_in_seconds          = lookup(var.deployment_config.blue_green_update_policy, "termination_wait_in_seconds", null)
        }
      }

      dynamic "auto_rollback_configuration" {
        for_each = lookup(var.deployment_config, "auto_rollback_configuration", null) != null ? [1] : []
        content {
          dynamic "alarms" {
            for_each = var.deployment_config.auto_rollback_configuration.alarms
            content {
              alarm_name = alarms.value.alarm_name
            }
          }
        }
      }

      dynamic "rolling_update_policy" {
        for_each = lookup(var.deployment_config, "rolling_update_policy", null) != null ? [1] : []
        content {
          maximum_execution_timeout_in_seconds = lookup(var.deployment_config.rolling_update_policy, "maximum_execution_timeout_in_seconds", null)
          wait_interval_in_seconds             = var.deployment_config.rolling_update_policy.wait_interval_in_seconds

          maximum_batch_size {
            type  = var.deployment_config.rolling_update_policy.maximum_batch_size.type
            value = var.deployment_config.rolling_update_policy.maximum_batch_size.value
          }

          rollback_maximum_batch_size {
            type  = lookup(var.deployment_config.rolling_update_policy.rollback_maximum_batch_size, "type", null)
            value = lookup(var.deployment_config.rolling_update_policy.rollback_maximum_batch_size, "value", null)
          }
        }
      }
    }
  }
}


###########################################################################################
############################ SageMaker Domain   #####################################
###########################################################################################

resource "aws_sagemaker_domain" "this" {
  count                         = var.create_domain ? 1 : 0
  domain_name                   = var.domain_name
  auth_mode                     = var.auth_mode
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
  app_network_access_type       = var.app_network_access_type
  app_security_group_management = var.app_security_group_management
  kms_key_id                    = var.kms_key_id
  tag_propagation               = var.tag_propagation

  default_user_settings {
    execution_role      = aws_iam_role.execution_role[0].arn
    security_groups     = concat(var.create_security_groups ? [for sg in module.arc_security_group : sg.id] : [], var.additional_security_group_ids)
    auto_mount_home_efs = var.default_user_settings.auto_mount_home_efs
    default_landing_uri = var.default_user_settings.default_landing_uri
    studio_web_portal   = var.default_user_settings.studio_web_portal

    # JupyterLab App Settings
    dynamic "jupyter_lab_app_settings" {
      for_each = var.default_user_settings.jupyter_lab_app_settings != null ? [var.default_user_settings.jupyter_lab_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = jupyter_lab_app_settings.value.default_resource_spec != null ? [jupyter_lab_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "app_lifecycle_management" {
          for_each = jupyter_lab_app_settings.value.app_lifecycle_management != null ? [jupyter_lab_app_settings.value.app_lifecycle_management] : []
          content {
            dynamic "idle_settings" {
              for_each = app_lifecycle_management.value.idle_settings != null ? [app_lifecycle_management.value.idle_settings] : []
              content {
                lifecycle_management        = idle_settings.value.lifecycle_management
                idle_timeout_in_minutes     = idle_settings.value.idle_timeout_in_minutes
                max_idle_timeout_in_minutes = idle_settings.value.max_idle_timeout_in_minutes
                min_idle_timeout_in_minutes = idle_settings.value.min_idle_timeout_in_minutes
              }
            }
          }
        }

        dynamic "custom_image" {
          for_each = jupyter_lab_app_settings.value.custom_images != null ? jupyter_lab_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }

        dynamic "code_repository" {
          for_each = jupyter_lab_app_settings.value.code_repositories != null ? jupyter_lab_app_settings.value.code_repositories : []
          content {
            repository_url = code_repository.value.repository_url
          }
        }

        lifecycle_config_arns         = jupyter_lab_app_settings.value.lifecycle_config_arns
        built_in_lifecycle_config_arn = jupyter_lab_app_settings.value.built_in_lifecycle_config_arn

        dynamic "emr_settings" {
          for_each = jupyter_lab_app_settings.value.emr_settings != null ? [jupyter_lab_app_settings.value.emr_settings] : []
          content {
            assumable_role_arns = emr_settings.value.assumable_role_arns
            execution_role_arns = emr_settings.value.execution_role
          }
        }
      }
    }

    # Code Editor App Settings
    dynamic "code_editor_app_settings" {
      for_each = var.default_user_settings.code_editor_app_settings != null ? [var.default_user_settings.code_editor_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = code_editor_app_settings.value.default_resource_spec != null ? [code_editor_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "app_lifecycle_management" {
          for_each = code_editor_app_settings.value.app_lifecycle_management != null ? [code_editor_app_settings.value.app_lifecycle_management] : []
          content {
            dynamic "idle_settings" {
              for_each = app_lifecycle_management.value.idle_settings != null ? [app_lifecycle_management.value.idle_settings] : []
              content {
                lifecycle_management        = idle_settings.value.lifecycle_management
                idle_timeout_in_minutes     = idle_settings.value.idle_timeout_in_minutes
                max_idle_timeout_in_minutes = idle_settings.value.max_idle_timeout_in_minutes
                min_idle_timeout_in_minutes = idle_settings.value.min_idle_timeout_in_minutes
              }
            }
          }
        }

        dynamic "custom_image" {
          for_each = code_editor_app_settings.value.custom_images != null ? code_editor_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }

        lifecycle_config_arns         = code_editor_app_settings.value.lifecycle_config_arns
        built_in_lifecycle_config_arn = code_editor_app_settings.value.built_in_lifecycle_config_arn
      }
    }

    # Jupyter Server App Settings
    dynamic "jupyter_server_app_settings" {
      for_each = var.default_user_settings.jupyter_server_app_settings != null ? [var.default_user_settings.jupyter_server_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = jupyter_server_app_settings.value.default_resource_spec != null ? [jupyter_server_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "code_repository" {
          for_each = jupyter_server_app_settings.value.code_repositories != null ? jupyter_server_app_settings.value.code_repositories : []
          content {
            repository_url = code_repository.value.repository_url
          }
        }

        lifecycle_config_arns = jupyter_server_app_settings.value.lifecycle_config_arns
      }
    }

    # Kernel Gateway App Settings
    dynamic "kernel_gateway_app_settings" {
      for_each = var.default_user_settings.kernel_gateway_app_settings != null ? [var.default_user_settings.kernel_gateway_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = kernel_gateway_app_settings.value.default_resource_spec != null ? [kernel_gateway_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "custom_image" {
          for_each = kernel_gateway_app_settings.value.custom_images != null ? kernel_gateway_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }

        lifecycle_config_arns = kernel_gateway_app_settings.value.lifecycle_config_arns
      }
    }

    # Canvas App Settings
    dynamic "canvas_app_settings" {
      for_each = var.default_user_settings.canvas_app_settings != null ? [var.default_user_settings.canvas_app_settings] : []
      content {
        dynamic "time_series_forecasting_settings" {
          for_each = canvas_app_settings.value.time_series_forecasting_settings != null ? [canvas_app_settings.value.time_series_forecasting_settings] : []
          content {
            status                   = time_series_forecasting_settings.value.status
            amazon_forecast_role_arn = time_series_forecasting_settings.value.amazon_forecast_role_arn
          }
        }

        dynamic "model_register_settings" {
          for_each = canvas_app_settings.value.model_register_settings != null ? [canvas_app_settings.value.model_register_settings] : []
          content {
            status                                = model_register_settings.value.status
            cross_account_model_register_role_arn = model_register_settings.value.cross_account_model_register_role_arn
          }
        }

        dynamic "workspace_settings" {
          for_each = canvas_app_settings.value.workspace_settings != null ? [canvas_app_settings.value.workspace_settings] : []
          content {
            s3_artifact_path = workspace_settings.value.s3_artifact_path
            s3_kms_key_id    = workspace_settings.value.s3_kms_key_id
          }
        }

        dynamic "direct_deploy_settings" {
          for_each = canvas_app_settings.value.direct_deploy_settings != null ? [canvas_app_settings.value.direct_deploy_settings] : []
          content {
            status = direct_deploy_settings.value.status
          }
        }

        dynamic "kendra_settings" {
          for_each = canvas_app_settings.value.kendra_settings != null ? [canvas_app_settings.value.kendra_settings] : []
          content {
            status = kendra_settings.value.status
          }
        }

        dynamic "identity_provider_oauth_settings" {
          for_each = canvas_app_settings.value.identity_provider_oauth_settings != null ? canvas_app_settings.value.identity_provider_oauth_settings : []
          content {
            data_source_name = identity_provider_oauth_settings.value.data_source_name
            secret_arn       = identity_provider_oauth_settings.value.secret_arn
            status           = identity_provider_oauth_settings.value.status
          }
        }

        dynamic "emr_serverless_settings" {
          for_each = canvas_app_settings.value.emr_serverless_settings != null ? [canvas_app_settings.value.emr_serverless_settings] : []
          content {
            execution_role_arn = emr_serverless_settings.value.execution_role_arn
            status             = emr_serverless_settings.value.status
          }
        }
      }
    }

    # TensorBoard App Settings
    dynamic "tensor_board_app_settings" {
      for_each = var.default_user_settings.tensor_board_app_settings != null ? [var.default_user_settings.tensor_board_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = tensor_board_app_settings.value.default_resource_spec != null ? [tensor_board_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }
      }
    }

    # R Session App Settings
    dynamic "r_session_app_settings" {
      for_each = var.default_user_settings.r_session_app_settings != null ? [var.default_user_settings.r_session_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = r_session_app_settings.value.default_resource_spec != null ? [r_session_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "custom_image" {
          for_each = r_session_app_settings.value.custom_images != null ? r_session_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }
      }
    }

    # RStudio Server Pro App Settings
    dynamic "r_studio_server_pro_app_settings" {
      for_each = var.default_user_settings.r_studio_server_pro_app_settings != null ? [var.default_user_settings.r_studio_server_pro_app_settings] : []
      content {
        access_status = r_studio_server_pro_app_settings.value.access_status
        user_group    = r_studio_server_pro_app_settings.value.user_group
      }
    }

    # Sharing Settings
    dynamic "sharing_settings" {
      for_each = var.default_user_settings.sharing_settings != null ? [var.default_user_settings.sharing_settings] : []
      content {
        notebook_output_option = sharing_settings.value.notebook_output_option
        s3_kms_key_id          = sharing_settings.value.s3_kms_key_id
        s3_output_path         = sharing_settings.value.s3_output_path
      }
    }

    # Space Storage Settings
    dynamic "space_storage_settings" {
      for_each = var.default_user_settings.space_storage_settings != null ? [var.default_user_settings.space_storage_settings] : []
      content {
        dynamic "default_ebs_storage_settings" {
          for_each = space_storage_settings.value.default_ebs_storage_settings != null ? [space_storage_settings.value.default_ebs_storage_settings] : []
          content {
            default_ebs_volume_size_in_gb = default_ebs_storage_settings.value.default_ebs_volume_size_in_gb
            maximum_ebs_volume_size_in_gb = default_ebs_storage_settings.value.maximum_ebs_volume_size_in_gb
          }
        }
      }
    }

    # Custom File System Config
    dynamic "custom_file_system_config" {
      for_each = var.default_user_settings.custom_file_system_config != null ? [var.default_user_settings.custom_file_system_config] : []
      content {
        dynamic "efs_file_system_config" {
          for_each = custom_file_system_config.value.efs_file_system_config != null ? [custom_file_system_config.value.efs_file_system_config] : []
          content {
            file_system_id   = efs_file_system_config.value.file_system_id
            file_system_path = efs_file_system_config.value.file_system_path
          }
        }
      }
    }

    # Custom POSIX User Config
    dynamic "custom_posix_user_config" {
      for_each = var.default_user_settings.custom_posix_user_config != null ? [var.default_user_settings.custom_posix_user_config] : []
      content {
        gid = custom_posix_user_config.value.gid
        uid = custom_posix_user_config.value.uid
      }
    }

    # Studio Web Portal Settings
    dynamic "studio_web_portal_settings" {
      for_each = var.default_user_settings.studio_web_portal_settings != null ? [var.default_user_settings.studio_web_portal_settings] : []
      content {
        hidden_app_types      = studio_web_portal_settings.value.hidden_app_types
        hidden_instance_types = studio_web_portal_settings.value.hidden_instance_types
        hidden_ml_tools       = studio_web_portal_settings.value.hidden_ml_tools
      }
    }
  }

  # Default Space Settings
  dynamic "default_space_settings" {
    for_each = var.default_space_settings != null ? [var.default_space_settings] : []
    content {
      execution_role  = default_space_settings.value.execution_role_arn
      security_groups = default_space_settings.value.security_groups

      # Similar nested blocks as user settings but for spaces
      dynamic "jupyter_server_app_settings" {
        for_each = default_space_settings.value.jupyter_server_app_settings != null ? [default_space_settings.value.jupyter_server_app_settings] : []
        content {
          dynamic "default_resource_spec" {
            for_each = jupyter_server_app_settings.value.default_resource_spec != null ? [jupyter_server_app_settings.value.default_resource_spec] : []
            content {
              instance_type                 = default_resource_spec.value.instance_type
              lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
              sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
              sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
              sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
            }
          }
        }
      }

      dynamic "kernel_gateway_app_settings" {
        for_each = default_space_settings.value.kernel_gateway_app_settings != null ? [default_space_settings.value.kernel_gateway_app_settings] : []
        content {
          dynamic "default_resource_spec" {
            for_each = kernel_gateway_app_settings.value.default_resource_spec != null ? [kernel_gateway_app_settings.value.default_resource_spec] : []
            content {
              instance_type                 = default_resource_spec.value.instance_type
              lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
              sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
              sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
              sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
            }
          }
        }
      }

      dynamic "jupyter_lab_app_settings" {
        for_each = default_space_settings.value.jupyter_lab_app_settings != null ? [default_space_settings.value.jupyter_lab_app_settings] : []
        content {
          dynamic "default_resource_spec" {
            for_each = jupyter_lab_app_settings.value.default_resource_spec != null ? [jupyter_lab_app_settings.value.default_resource_spec] : []
            content {
              instance_type                 = default_resource_spec.value.instance_type
              lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
              sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
              sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
              sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
            }
          }
        }
      }

      dynamic "space_storage_settings" {
        for_each = default_space_settings.value.space_storage_settings != null ? [default_space_settings.value.space_storage_settings] : []
        content {
          dynamic "default_ebs_storage_settings" {
            for_each = space_storage_settings.value.default_ebs_storage_settings != null ? [space_storage_settings.value.default_ebs_storage_settings] : []
            content {
              default_ebs_volume_size_in_gb = default_ebs_storage_settings.value.default_ebs_volume_size_in_gb
              maximum_ebs_volume_size_in_gb = default_ebs_storage_settings.value.maximum_ebs_volume_size_in_gb
            }
          }
        }
      }

      dynamic "custom_file_system_config" {
        for_each = default_space_settings.value.custom_file_system_config != null ? [default_space_settings.value.custom_file_system_config] : []
        content {
          dynamic "efs_file_system_config" {
            for_each = custom_file_system_config.value.efs_file_system_config != null ? [custom_file_system_config.value.efs_file_system_config] : []
            content {
              file_system_id   = efs_file_system_config.value.file_system_id
              file_system_path = efs_file_system_config.value.file_system_path
            }
          }
        }
      }

      dynamic "custom_posix_user_config" {
        for_each = default_space_settings.value.custom_posix_user_config != null ? [default_space_settings.value.custom_posix_user_config] : []
        content {
          gid = custom_posix_user_config.value.gid
          uid = custom_posix_user_config.value.uid
        }
      }
    }
  }

  # Domain Settings
  dynamic "domain_settings" {
    for_each = var.domain_settings != null ? [var.domain_settings] : []
    content {
      execution_role_identity_config = domain_settings.value.execution_role_identity_config
      security_group_ids             = domain_settings.value.security_group_ids

      dynamic "docker_settings" {
        for_each = domain_settings.value.docker_settings != null ? [domain_settings.value.docker_settings] : []
        content {
          enable_docker_access      = docker_settings.value.enable_docker_access
          vpc_only_trusted_accounts = docker_settings.value.vpc_only_trusted_accounts
        }
      }

      dynamic "r_studio_server_pro_domain_settings" {
        for_each = domain_settings.value.r_studio_server_pro_domain_settings != null ? [domain_settings.value.r_studio_server_pro_domain_settings] : []
        content {
          domain_execution_role_arn    = r_studio_server_pro_domain_settings.value.domain_execution_role_arn
          r_studio_connect_url         = r_studio_server_pro_domain_settings.value.r_studio_connect_url
          r_studio_package_manager_url = r_studio_server_pro_domain_settings.value.r_studio_package_manager_url

          dynamic "default_resource_spec" {
            for_each = r_studio_server_pro_domain_settings.value.default_resource_spec != null ? [r_studio_server_pro_domain_settings.value.default_resource_spec] : []
            content {
              instance_type                 = default_resource_spec.value.instance_type
              lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
              sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
              sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
              sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
            }
          }
        }
      }
    }
  }

  # Retention Policy
  dynamic "retention_policy" {
    for_each = var.retention_policy != null ? [var.retention_policy] : []
    content {
      home_efs_file_system = retention_policy.value.home_efs_file_system
    }
  }

  tags = var.tags
}
################################################################################################
# SageMaker User Profiles
################################################################################################
resource "aws_sagemaker_user_profile" "this" {
  for_each = var.create_user_profile && var.create_domain ? {
    for profile in var.user_profiles : profile.name => profile
  } : {}

  domain_id                      = aws_sagemaker_domain.this[0].id
  user_profile_name              = each.value.name
  single_sign_on_user_identifier = each.value.single_sign_on_user_identifier
  single_sign_on_user_value      = each.value.single_sign_on_user_value

  user_settings {
    execution_role      = aws_iam_role.execution_role[0].arn
    security_groups     = each.value.user_settings != null && each.value.user_settings.security_groups != null ? each.value.user_settings.security_groups : concat(var.create_security_groups ? [for sg in module.arc_security_group : sg.id] : [], var.additional_security_group_ids)
    auto_mount_home_efs = try(each.value.user_settings.auto_mount_home_efs, null)
    default_landing_uri = try(each.value.user_settings.default_landing_uri, null)
    studio_web_portal   = try(each.value.user_settings.studio_web_portal, null)

    # JupyterLab App Settings for User Profile
    dynamic "jupyter_lab_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.jupyter_lab_app_settings != null ? [each.value.user_settings.jupyter_lab_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = jupyter_lab_app_settings.value.default_resource_spec != null ? [jupyter_lab_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "app_lifecycle_management" {
          for_each = jupyter_lab_app_settings.value.app_lifecycle_management != null ? [jupyter_lab_app_settings.value.app_lifecycle_management] : []
          content {
            dynamic "idle_settings" {
              for_each = app_lifecycle_management.value.idle_settings != null ? [app_lifecycle_management.value.idle_settings] : []
              content {
                lifecycle_management        = idle_settings.value.lifecycle_management
                idle_timeout_in_minutes     = idle_settings.value.idle_timeout_in_minutes
                max_idle_timeout_in_minutes = idle_settings.value.max_idle_timeout_in_minutes
                min_idle_timeout_in_minutes = idle_settings.value.min_idle_timeout_in_minutes
              }
            }
          }
        }

        dynamic "custom_image" {
          for_each = jupyter_lab_app_settings.value.custom_images != null ? jupyter_lab_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }

        dynamic "code_repository" {
          for_each = jupyter_lab_app_settings.value.code_repositories != null ? jupyter_lab_app_settings.value.code_repositories : []
          content {
            repository_url = code_repository.value.repository_url
          }
        }

        lifecycle_config_arns         = jupyter_lab_app_settings.value.lifecycle_config_arns
        built_in_lifecycle_config_arn = jupyter_lab_app_settings.value.built_in_lifecycle_config_arn

        dynamic "emr_settings" {
          for_each = jupyter_lab_app_settings.value.emr_settings != null ? [jupyter_lab_app_settings.value.emr_settings] : []
          content {
            assumable_role_arns = emr_settings.value.assumable_role_arns
            execution_role_arns = emr_settings.value.execution_role_arns
          }
        }
      }
    }

    # Code Editor App Settings for User Profile
    dynamic "code_editor_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.code_editor_app_settings != null ? [each.value.user_settings.code_editor_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = code_editor_app_settings.value.default_resource_spec != null ? [code_editor_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "app_lifecycle_management" {
          for_each = code_editor_app_settings.value.app_lifecycle_management != null ? [code_editor_app_settings.value.app_lifecycle_management] : []
          content {
            dynamic "idle_settings" {
              for_each = app_lifecycle_management.value.idle_settings != null ? [app_lifecycle_management.value.idle_settings] : []
              content {
                lifecycle_management        = idle_settings.value.lifecycle_management
                idle_timeout_in_minutes     = idle_settings.value.idle_timeout_in_minutes
                max_idle_timeout_in_minutes = idle_settings.value.max_idle_timeout_in_minutes
                min_idle_timeout_in_minutes = idle_settings.value.min_idle_timeout_in_minutes
              }
            }
          }
        }

        dynamic "custom_image" {
          for_each = code_editor_app_settings.value.custom_images != null ? code_editor_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }

        lifecycle_config_arns         = code_editor_app_settings.value.lifecycle_config_arns
        built_in_lifecycle_config_arn = code_editor_app_settings.value.built_in_lifecycle_config_arn
      }
    }

    # Canvas App Settings for User Profile
    dynamic "canvas_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.canvas_app_settings != null ? [each.value.user_settings.canvas_app_settings] : []
      content {
        dynamic "time_series_forecasting_settings" {
          for_each = canvas_app_settings.value.time_series_forecasting_settings != null ? [canvas_app_settings.value.time_series_forecasting_settings] : []
          content {
            status                   = time_series_forecasting_settings.value.status
            amazon_forecast_role_arn = time_series_forecasting_settings.value.amazon_forecast_role_arn
          }
        }

        dynamic "model_register_settings" {
          for_each = canvas_app_settings.value.model_register_settings != null ? [canvas_app_settings.value.model_register_settings] : []
          content {
            status                                = model_register_settings.value.status
            cross_account_model_register_role_arn = model_register_settings.value.cross_account_model_register_role_arn
          }
        }

        dynamic "workspace_settings" {
          for_each = canvas_app_settings.value.workspace_settings != null ? [canvas_app_settings.value.workspace_settings] : []
          content {
            s3_artifact_path = workspace_settings.value.s3_artifact_path
            s3_kms_key_id    = workspace_settings.value.s3_kms_key_id
          }
        }

        dynamic "direct_deploy_settings" {
          for_each = canvas_app_settings.value.direct_deploy_settings != null ? [canvas_app_settings.value.direct_deploy_settings] : []
          content {
            status = direct_deploy_settings.value.status
          }
        }

        dynamic "kendra_settings" {
          for_each = canvas_app_settings.value.kendra_settings != null ? [canvas_app_settings.value.kendra_settings] : []
          content {
            status = kendra_settings.value.status
          }
        }

        dynamic "identity_provider_oauth_settings" {
          for_each = canvas_app_settings.value.identity_provider_oauth_settings != null ? canvas_app_settings.value.identity_provider_oauth_settings : []
          content {
            data_source_name = identity_provider_oauth_settings.value.data_source_name
            secret_arn       = identity_provider_oauth_settings.value.secret_arn
            status           = identity_provider_oauth_settings.value.status
          }
        }

        dynamic "emr_serverless_settings" {
          for_each = canvas_app_settings.value.emr_serverless_settings != null ? [canvas_app_settings.value.emr_serverless_settings] : []
          content {
            execution_role_arn = emr_serverless_settings.value.execution_role_arn
            status             = emr_serverless_settings.value.status
          }
        }
      }
    }

    # Additional app settings (Jupyter Server, Kernel Gateway, TensorBoard, R Session, RStudio Server Pro)
    dynamic "jupyter_server_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.jupyter_server_app_settings != null ? [each.value.user_settings.jupyter_server_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = jupyter_server_app_settings.value.default_resource_spec != null ? [jupyter_server_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "code_repository" {
          for_each = jupyter_server_app_settings.value.code_repositories != null ? jupyter_server_app_settings.value.code_repositories : []
          content {
            repository_url = code_repository.value.repository_url
          }
        }

        lifecycle_config_arns = jupyter_server_app_settings.value.lifecycle_config_arns
      }
    }

    dynamic "kernel_gateway_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.kernel_gateway_app_settings != null ? [each.value.user_settings.kernel_gateway_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = kernel_gateway_app_settings.value.default_resource_spec != null ? [kernel_gateway_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "custom_image" {
          for_each = kernel_gateway_app_settings.value.custom_images != null ? kernel_gateway_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }

        lifecycle_config_arns = kernel_gateway_app_settings.value.lifecycle_config_arns
      }
    }

    dynamic "tensor_board_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.tensor_board_app_settings != null ? [each.value.user_settings.tensor_board_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = tensor_board_app_settings.value.default_resource_spec != null ? [tensor_board_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }
      }
    }

    dynamic "r_session_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.r_session_app_settings != null ? [each.value.user_settings.r_session_app_settings] : []
      content {
        dynamic "default_resource_spec" {
          for_each = r_session_app_settings.value.default_resource_spec != null ? [r_session_app_settings.value.default_resource_spec] : []
          content {
            instance_type                 = default_resource_spec.value.instance_type
            lifecycle_config_arn          = default_resource_spec.value.lifecycle_config_arn
            sagemaker_image_arn           = default_resource_spec.value.sagemaker_image_arn
            sagemaker_image_version_arn   = default_resource_spec.value.sagemaker_image_version_arn
            sagemaker_image_version_alias = default_resource_spec.value.sagemaker_image_version_alias
          }
        }

        dynamic "custom_image" {
          for_each = r_session_app_settings.value.custom_images != null ? r_session_app_settings.value.custom_images : []
          content {
            app_image_config_name = custom_image.value.app_image_config_name
            image_name            = custom_image.value.image_name
            image_version_number  = custom_image.value.image_version_number
          }
        }
      }
    }

    dynamic "r_studio_server_pro_app_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.r_studio_server_pro_app_settings != null ? [each.value.user_settings.r_studio_server_pro_app_settings] : []
      content {
        access_status = r_studio_server_pro_app_settings.value.access_status
        user_group    = r_studio_server_pro_app_settings.value.user_group
      }
    }

    # Sharing Settings for User Profile
    dynamic "sharing_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.sharing_settings != null ? [each.value.user_settings.sharing_settings] : []
      content {
        notebook_output_option = sharing_settings.value.notebook_output_option
        s3_kms_key_id          = sharing_settings.value.s3_kms_key_id
        s3_output_path         = sharing_settings.value.s3_output_path
      }
    }

    # Space Storage Settings for User Profile
    dynamic "space_storage_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.space_storage_settings != null ? [each.value.user_settings.space_storage_settings] : []
      content {
        dynamic "default_ebs_storage_settings" {
          for_each = space_storage_settings.value.default_ebs_storage_settings != null ? [space_storage_settings.value.default_ebs_storage_settings] : []
          content {
            default_ebs_volume_size_in_gb = default_ebs_storage_settings.value.default_ebs_volume_size_in_gb
            maximum_ebs_volume_size_in_gb = default_ebs_storage_settings.value.maximum_ebs_volume_size_in_gb
          }
        }
      }
    }

    # Custom File System Config for User Profile
    dynamic "custom_file_system_config" {
      for_each = each.value.user_settings != null && each.value.user_settings.custom_file_system_config != null ? [each.value.user_settings.custom_file_system_config] : []
      content {
        dynamic "efs_file_system_config" {
          for_each = custom_file_system_config.value.efs_file_system_config != null ? [custom_file_system_config.value.efs_file_system_config] : []
          content {
            file_system_id   = efs_file_system_config.value.file_system_id
            file_system_path = efs_file_system_config.value.file_system_path
          }
        }
      }
    }

    # Custom POSIX User Config for User Profile
    dynamic "custom_posix_user_config" {
      for_each = each.value.user_settings != null && each.value.user_settings.custom_posix_user_config != null ? [each.value.user_settings.custom_posix_user_config] : []
      content {
        gid = custom_posix_user_config.value.gid
        uid = custom_posix_user_config.value.uid
      }
    }

    # Studio Web Portal Settings for User Profile
    dynamic "studio_web_portal_settings" {
      for_each = each.value.user_settings != null && each.value.user_settings.studio_web_portal_settings != null ? [each.value.user_settings.studio_web_portal_settings] : []
      content {
        hidden_app_types      = studio_web_portal_settings.value.hidden_app_types
        hidden_instance_types = studio_web_portal_settings.value.hidden_instance_types
        hidden_ml_tools       = studio_web_portal_settings.value.hidden_ml_tools
      }
    }
  }

  tags = var.tags
}
################################################################################################
#################################### SageMaker Pipelines #######################################
################################################################################################
resource "aws_sagemaker_pipeline" "this" {
  for_each = var.create_pipeline ? {
    for pipeline in var.pipelines : pipeline.name => pipeline
  } : {}

  pipeline_name         = each.value.name
  pipeline_display_name = each.value.display_name
  pipeline_description  = each.value.description
  role_arn              = each.value.role_arn != null ? each.value.role_arn : aws_iam_role.pipeline_role[0].arn
  # Pipeline Definition (either inline JSON or S3 location)
  pipeline_definition = each.value.definition

  dynamic "pipeline_definition_s3_location" {
    for_each = each.value.pipeline_definition_s3_location != null ? [each.value.pipeline_definition_s3_location] : []
    content {
      bucket     = pipeline_definition_s3_location.value.bucket
      object_key = pipeline_definition_s3_location.value.object_key
      version_id = pipeline_definition_s3_location.value.version_id
    }
  }

  dynamic "parallelism_configuration" {
    for_each = each.value.parallelism_configuration != null ? [each.value.parallelism_configuration] : []
    content {
      max_parallel_execution_steps = parallelism_configuration.value.max_parallel_execution_steps
    }
  }

  tags = var.tags
}

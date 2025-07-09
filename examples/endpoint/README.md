<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sagemaker_model"></a> [sagemaker\_model](#module\_sagemaker\_model) | ../.. | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.6 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_config_arn"></a> [endpoint\_config\_arn](#output\_endpoint\_config\_arn) | ARN of the SageMaker endpoint configuration |
| <a name="output_model_arn"></a> [model\_arn](#output\_model\_arn) | ARN of the SageMaker model |
| <a name="output_model_name"></a> [model\_name](#output\_model\_name) | Name of the SageMaker model |
<!-- END_TF_DOCS -->

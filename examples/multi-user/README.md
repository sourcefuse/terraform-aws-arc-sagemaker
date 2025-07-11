<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sagemaker_studio_multi_user"></a> [sagemaker\_studio\_multi\_user](#module\_sagemaker\_studio\_multi\_user) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.6 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.sagemaker_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_execution_role"></a> [create\_execution\_role](#input\_create\_execution\_role) | Whether to create a default execution role | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_input_data_s3_uri"></a> [input\_data\_s3\_uri](#input\_input\_data\_s3\_uri) | S3 URI for input data in shared pipeline | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID for encryption | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. arc | `string` | n/a | yes |
| <a name="input_output_data_s3_path"></a> [output\_data\_s3\_path](#input\_output\_data\_s3\_path) | S3 path for pipeline output data | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_security_group_data"></a> [security\_group\_data](#input\_security\_group\_data) | (optional) Security Group data | <pre>object({<br/>    security_group_ids_to_attach = optional(list(string), [])<br/>    create                       = optional(bool, true)<br/>    description                  = optional(string, null)<br/>    ingress_rules = optional(list(object({<br/>      description              = optional(string, null)<br/>      cidr_block               = optional(string, null)<br/>      source_security_group_id = optional(string, null)<br/>      from_port                = number<br/>      ip_protocol              = string<br/>      to_port                  = string<br/>      self                     = optional(bool, false)<br/>    })), [])<br/>    egress_rules = optional(list(object({<br/>      description                   = optional(string, null)<br/>      cidr_block                    = optional(string, null)<br/>      destination_security_group_id = optional(string, null)<br/>      from_port                     = number<br/>      ip_protocol                   = string<br/>      to_port                       = string<br/>      prefix_list_id                = optional(string, null)<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "create": false<br/>}</pre> | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | sagemaker security group name | `string` | n/a | yes |
| <a name="input_shared_s3_path"></a> [shared\_s3\_path](#input\_shared\_s3\_path) | S3 path for shared notebook outputs | `string` | n/a | yes |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | List of subnet names to lookup | `list(string)` | <pre>[<br/>  "arc-poc-private-subnet-private-us-east-1a",<br/>  "arc-poc-private-subnet-private-us-east-1b"<br/>]</pre> | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC to add the resources | `string` | `"arc-poc-vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | SageMaker Domain ID |
| <a name="output_domain_url"></a> [domain\_url](#output\_domain\_url) | URL to access SageMaker Studio |
| <a name="output_pipeline_arns"></a> [pipeline\_arns](#output\_pipeline\_arns) | Map of pipeline names to their ARNs |
| <a name="output_user_profiles"></a> [user\_profiles](#output\_user\_profiles) | Map of user profile names to their ARNs |
<!-- END_TF_DOCS -->

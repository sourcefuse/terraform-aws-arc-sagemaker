resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.name}-sagemaker-execution-role"

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
# IAM Role for SageMaker Execution
resource "aws_iam_role" "execution_role" {
  count = var.create_execution_role ? 1 : 0

  name = var.execution_role_name
  path = var.execution_role_path

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = var.execution_role_name
  })
}

# Attach AWS managed policies to the execution role
locals {
  all_execution_role_policies = var.create_execution_role ? toset(
    concat(
      ["arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"],
      var.additional_iam_policies
    )
  ) : []
}

resource "aws_iam_role_policy_attachment" "execution_role_all_policies" {
  for_each = local.all_execution_role_policies

  role       = aws_iam_role.execution_role[0].name
  policy_arn = each.value
}

# Custom IAM policy for SageMaker Studio
resource "aws_iam_role_policy" "execution_role_custom" {
  count = var.create_execution_role ? 1 : 0

  name = "${var.execution_role_name}-custom-policy"
  role = aws_iam_role.execution_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:*",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "iam:GetRole",
          "iam:PassRole",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeDhcpOptions",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = aws_iam_role.execution_role[0].arn
      },
    ]
  })
}

# IAM Role for SageMaker Pipelines (if different from execution role)
resource "aws_iam_role" "pipeline_role" {
  count = var.create_pipeline_role ? 1 : 0

  name = var.pipeline_role_name
  path = var.pipeline_role_path

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = var.pipeline_role_name
  })
}

# Attach policies to pipeline role
resource "aws_iam_role_policy_attachment" "pipeline_role_sagemaker_full_access" {
  count = var.create_pipeline_role ? 1 : 0

  role       = aws_iam_role.pipeline_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Custom IAM policy for SageMaker Pipelines
resource "aws_iam_role_policy" "pipeline_role_custom" {
  count = var.create_pipeline_role ? 1 : 0

  name = "${var.pipeline_role_name}-custom-policy"
  role = aws_iam_role.pipeline_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:*",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "iam:GetRole",
          "iam:PassRole",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule",
          "lambda:InvokeFunction"
        ]
        Resource = aws_iam_role.pipeline_role[0].arn
      }
    ]
  })
}

###################################################################
#                Security Group
###################################################################
module "arc_security_group" {
  source  = "sourcefuse/arc-security-group/aws"
  version = "0.0.1"

  count         = var.create_security_groups ? 1 : 0
  name          = var.security_group_name
  vpc_id        = var.vpc_id
  ingress_rules = var.security_group_data.ingress_rules
  egress_rules  = var.security_group_data.egress_rules

  tags = var.tags
}

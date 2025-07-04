
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
resource "aws_iam_role_policy_attachment" "execution_role_sagemaker_full_access" {
  count = var.create_execution_role ? 1 : 0

  role       = aws_iam_role.execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "execution_role_s3_full_access" {
  count = var.create_execution_role && contains(var.additional_iam_policies, "arn:aws:iam::aws:policy/AmazonS3FullAccess") ? 1 : 0

  role       = aws_iam_role.execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "execution_role_emr_full_access" {
  count = var.create_execution_role && contains(var.additional_iam_policies, "arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2") ? 1 : 0

  role       = aws_iam_role.execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2"
}

# Attach additional IAM policies
resource "aws_iam_role_policy_attachment" "execution_role_additional" {
  for_each = var.create_execution_role ? toset(var.additional_iam_policies) : []

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
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::sagemaker-*/*",
          "arn:aws:s3:::*sagemaker*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::sagemaker-*",
          "arn:aws:s3:::*sagemaker*"
        ]
      }
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
        Resource = "*"
      }
    ]
  })
}

# Security Group for SageMaker Studio
resource "aws_security_group" "sagemaker" {
  count = var.create_security_groups ? 1 : 0

  name_prefix = "${var.domain_name}-sagemaker-"
  description = "Security group for SageMaker Studio Domain ${var.domain_name}"
  vpc_id      = var.vpc_id

  # Ingress rules
  dynamic "ingress" {
    for_each = var.security_group_ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      security_groups  = ingress.value.security_groups
      self             = ingress.value.self
    }
  }

  # Default ingress rule for HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Default ingress rule for NFS (if using EFS)
  ingress {
    description = "NFS for EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    self        = true
  }

  # Egress rules
  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
      security_groups  = egress.value.security_groups
      self             = egress.value.self
    }
  }

  # Default egress rule
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.domain_name}-sagemaker-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for EFS (if using custom file system)
resource "aws_security_group" "efs" {
  count = var.create_security_groups && var.create_efs_security_group ? 1 : 0

  name_prefix = "${var.domain_name}-efs-"
  description = "Security group for EFS used by SageMaker Studio Domain ${var.domain_name}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from SageMaker"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.sagemaker[0].id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.domain_name}-efs-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

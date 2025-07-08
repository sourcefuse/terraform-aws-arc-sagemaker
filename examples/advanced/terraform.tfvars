region              = "us-east-1"
environment         = "poc"
namespace           = "arc"
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

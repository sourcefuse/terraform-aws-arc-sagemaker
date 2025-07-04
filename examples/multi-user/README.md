# SageMaker Studio Multi-User Example

This example demonstrates a team-oriented SageMaker Studio setup with multiple user profiles, role-based access control, and shared resources for collaborative machine learning projects.

## 🏗️ AWS Services Created

### Core SageMaker Services
- **1x SageMaker Domain** (`multi-user-ml-domain`)
  - IAM authentication with VPC-only access
  - Shared configuration optimized for team collaboration
  - Lifecycle management for cost control

- **5x SageMaker User Profiles**:
  - **`ds-team-lead`**: Team leadership with enhanced resources
  - **`senior-data-scientist`**: Full ML capabilities
  - **`junior-data-scientist`**: Restricted access with cost controls
  - **`ml-engineer`**: Engineering-focused with deployment tools
  - **`data-analyst`**: Analytics-focused with simplified interface

- **1x SageMaker Pipeline**:
  - **`shared-data-pipeline`**: Common data processing for all users

### Supporting Infrastructure
- **1x Custom Security Group**: Team-wide networking rules
- **1x Shared S3 Integration**: Collaborative workspace storage

### IAM Resources (Optional)
- **1x Multi-User Execution Role** (if `create_execution_role = true`)
- **Role-Based Access Control**: Different permissions per user type
- **2x IAM Policy Attachments**: S3 access and SageMaker permissions

## 👥 User Profile Configurations

### Data Science Team Lead
- **Instance Type**: `ml.m5.xlarge` (4 vCPU, 16 GB RAM)
- **Permissions**: Full access to all features
- **Storage**: Dedicated S3 path for team coordination
- **Use Case**: Team management, architecture decisions, code reviews

### Senior Data Scientist
- **Instance Type**: `ml.m5.large` (2 vCPU, 8 GB RAM)
- **Permissions**: Full ML development capabilities
- **Storage**: Personal workspace with team sharing
- **Use Case**: Advanced modeling, research, mentoring

### Junior Data Scientist
- **Instance Type**: `ml.t3.large` (2 vCPU, 8 GB RAM)
- **Permissions**: Restricted expensive instance access
- **Restrictions**: No GPU instances (P3 family blocked)
- **Use Case**: Learning, basic modeling, data exploration

### ML Engineer
- **Instance Type**: `ml.m5.xlarge` (4 vCPU, 16 GB RAM)
- **Features**: Enhanced Code Editor access
- **Focus**: Model deployment, pipeline development
- **Use Case**: MLOps, production deployment, infrastructure

### Data Analyst
- **Instance Type**: `ml.t3.large` (2 vCPU, 8 GB RAM)
- **Restrictions**: No TensorBoard, limited GPU access
- **Focus**: Data analysis and visualization
- **Use Case**: Business intelligence, reporting, basic analytics

## 🔄 Shared Resources

### Collaborative Pipeline
- **Purpose**: Common data processing workflows
- **Access**: Available to all team members
- **Configuration**: Moderate parallelism (2 steps)
- **Instance**: `ml.m5.large` for cost efficiency

### Shared Storage Structure
```
s3://your-bucket/shared-outputs/
├── team-lead/          # Team lead workspace
├── senior-ds/          # Senior data scientist workspace
├── junior-ds/          # Junior data scientist workspace
├── ml-engineer/        # ML engineer workspace
├── data-analyst/       # Data analyst workspace
└── shared/             # Common team resources
```

## 💰 Cost Management Strategy

### Tiered Instance Allocation
- **Leadership**: Higher-performance instances for complex work
- **Junior Staff**: Cost-effective instances for learning
- **Specialists**: Appropriate sizing for specific roles

### Lifecycle Management
- **Idle Timeout**: 120 minutes (balanced for collaboration)
- **Range**: 60-480 minutes (flexible for different work patterns)
- **Auto-shutdown**: Prevents runaway costs

### Access Controls
- **GPU Restrictions**: Junior roles blocked from expensive instances
- **Instance Limits**: Appropriate sizing per role level
- **Feature Restrictions**: Simplified interfaces for specific roles

## 🔒 Security & Governance

### Role-Based Access Control (RBAC)
- **Principle of Least Privilege**: Each role has minimum required permissions
- **Separation of Duties**: Different capabilities per user type
- **Audit Trail**: All actions tracked through CloudTrail

### Data Protection
- **VPC Isolation**: No public internet access
- **Encryption**: Optional KMS encryption for sensitive data
- **Access Logging**: Comprehensive audit capabilities

### Compliance Features
- **Resource Tagging**: Cost center, owner, environment tracking
- **Access Reviews**: Regular permission audits
- **Data Governance**: Controlled data access patterns

## 📋 Prerequisites

### Network Requirements
- **VPC**: With private subnets in multiple AZs
- **Connectivity**: VPC endpoints for AWS services (recommended)
- **DNS**: Proper DNS resolution for internal services

### IAM Requirements
- **Execution Roles**: One per user type with appropriate permissions
- **Pipeline Role**: For automated workflow execution
- **Cross-Service Access**: S3, CloudWatch, other AWS services

### Storage Requirements
- **S3 Buckets**: For shared outputs and data storage
- **Permissions**: Proper bucket policies for team access
- **Organization**: Structured folder hierarchy for collaboration

## 🚀 Deployment Guide

### 1. Prepare IAM Roles
```bash
# Create roles for each user type
aws iam create-role --role-name SageMakerTeamLeadRole --assume-role-policy-document file://trust-policy.json
aws iam create-role --role-name SageMakerSeniorDSRole --assume-role-policy-document file://trust-policy.json
# ... repeat for other roles
```

### 2. Configure Variables
```bash
# Copy and customize the example
cp terraform.tfvars.example terraform.tfvars
# Edit with your specific values
```

### 3. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 4. User Onboarding
```bash
# Verify user profiles
aws sagemaker list-user-profiles --domain-id-equals <domain-id>

# Test access for each user
aws sagemaker create-presigned-domain-url --domain-id <domain-id> --user-profile-name ds-team-lead
```

## 📊 Expected Costs (Monthly)

**Assuming 8 hours/day, 22 days/month per user:**

### Compute Costs by Role
- **Team Lead** (ml.m5.xlarge): ~$140-180/month
- **Senior DS** (ml.m5.large): ~$70-90/month
- **Junior DS** (ml.t3.large): ~$35-50/month
- **ML Engineer** (ml.m5.xlarge): ~$140-180/month
- **Data Analyst** (ml.t3.large): ~$35-50/month

### Storage Costs
- **EBS per user**: ~$15-25/month each (5 users = $75-125/month)
- **S3 shared storage**: ~$10-30/month
- **Pipeline artifacts**: ~$5-15/month

### Total Team Cost
- **Compute**: $420-550/month
- **Storage**: $90-170/month
- **Total**: $510-720/month

**Cost per user**: ~$100-145/month

## 🎯 Team Collaboration Features

### Shared Resources
- **Common Pipelines**: Reusable workflows for all team members
- **Shared Storage**: Collaborative workspace with organized structure
- **Code Repositories**: Integrated GitHub access for version control

### Knowledge Sharing
- **Notebook Sharing**: Easy sharing of analysis and models
- **Documentation**: Built-in documentation capabilities
- **Version Control**: Git integration for collaborative development

### Workflow Management
- **Pipeline Orchestration**: Automated ML workflows
- **Resource Scheduling**: Efficient resource utilization
- **Progress Tracking**: Visibility into team activities

## 🔧 Customization Options

### Adding New Team Members
```hcl
# Add to user_profiles list
{
  name               = "new-team-member"
  execution_role_arn = var.new_member_role_arn
  user_settings = {
    jupyter_lab_app_settings = {
      default_resource_spec = {
        instance_type = "ml.t3.large"  # Start with cost-effective option
      }
    }
  }
}
```

### Role Modifications
```hcl
# Upgrade junior to senior permissions
user_settings = {
  studio_web_portal_settings = {
    # Remove restrictions
    hidden_instance_types = []  # Allow access to more instances
  }
}
```

### Team-Specific Pipelines
```hcl
# Add specialized pipeline
{
  name = "model-validation-pipeline"
  display_name = "Team-Model-Validation"
  description = "Standardized model validation for team"
  # ... pipeline definition
}
```

## 🛠️ Management & Monitoring

### Daily Operations
```bash
# Check team usage
aws sagemaker list-user-profiles --domain-id-equals <domain-id> --query 'UserProfiles[*].[UserProfileName,Status,LastModifiedTime]'

# Monitor costs
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics BlendedCost --group-by Type=DIMENSION,Key=SERVICE
```

### Weekly Reviews
- **Usage Analysis**: Review instance utilization per user
- **Cost Optimization**: Identify opportunities for savings
- **Access Review**: Ensure appropriate permissions
- **Performance Tuning**: Adjust instance types based on usage

### Monthly Tasks
- **Role Updates**: Adjust permissions based on team evolution
- **Cost Analysis**: Detailed cost breakdown and optimization
- **Capacity Planning**: Plan for team growth or changes
- **Security Review**: Audit access patterns and permissions

## 📈 Scaling Strategies

### Team Growth
1. **Add User Profiles**: Scale horizontally with new team members
2. **Role Evolution**: Promote users to higher-privilege roles
3. **Specialization**: Create specialized roles for specific functions

### Resource Optimization
1. **Instance Right-sizing**: Adjust based on actual usage patterns
2. **Shared Resources**: Increase shared pipeline usage
3. **Cost Controls**: Implement automated cost alerts and limits

### Advanced Features
1. **Custom Images**: Team-specific ML environments
2. **Feature Store**: Centralized feature management
3. **Model Registry**: Team model governance

## 🔄 Best Practices

### Team Management
- **Regular Training**: Keep team updated on new features
- **Usage Guidelines**: Establish clear usage policies
- **Cost Awareness**: Educate team on cost implications
- **Collaboration Standards**: Define sharing and naming conventions

### Security Practices
- **Regular Audits**: Review permissions and access patterns
- **Credential Rotation**: Regular IAM credential updates
- **Data Classification**: Proper handling of sensitive data
- **Incident Response**: Clear procedures for security issues

### Operational Excellence
- **Monitoring**: Comprehensive usage and performance monitoring
- **Automation**: Automate routine management tasks
- **Documentation**: Maintain up-to-date team documentation
- **Feedback Loop**: Regular team feedback on platform usage

## 📚 Next Steps

1. **Team Onboarding**: Train each user on their specific environment
2. **Workflow Development**: Create team-specific ML workflows
3. **Integration**: Connect to team data sources and tools
4. **Governance**: Implement team ML governance processes
5. **Optimization**: Continuously optimize based on usage patterns

---

**Total Resources Created**: 8-10
**Team Size**: 5 users
**Estimated Setup Time**: 45-60 minutes
**Skill Level**: Intermediate
**Team Ready**: ✅

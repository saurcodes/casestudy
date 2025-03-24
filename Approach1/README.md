# Zantac Cloud Migration - Approach 1: Lift and Shift with Incremental Modernization

## Overview
This repository contains the Infrastructure as Code (IaC) for migrating Zantac's applications to AWS using a lift and shift approach with incremental modernization. The infrastructure is defined using Terraform and configured with Ansible.

## Architecture
The architecture follows a traditional three-tier design with separate subnets for web/application/database tiers spread across multiple Availability Zones for high availability:

- **Public Subnets**: Contains Application Load Balancers (ALBs) for traffic distribution
- **Application Subnets**: Houses EC2 instances within Auto Scaling Groups (ASGs) for the application tier
- **Database Subnets**: Contains RDS instances for Oracle databases

## Prerequisites
- AWS Account
- Terraform ≥ 1.0.0
- Ansible ≥ 2.9
- AWS CLI configured with appropriate credentials
- Jenkins (optional, for CI/CD pipeline)

## Directory Structure
```
lift-and-shift/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc.tf
│   ├── security.tf
│   ├── ec2.tf
│   ├── rds.tf
│   ├── lb.tf
│   └── iam.tf
├── ansible/
│   ├── inventory/
│   ├── group_vars/
│   ├── playbooks/
│   │   ├── webserver.yml
│   │   ├── middleware.yml
│   │   └── database.yml
│   └── roles/
│       ├── common/
│       ├── webserver/
│       ├── middleware/
│       └── database/
└── jenkins/
    └── Jenkinsfile
```

## Installation & Usage

### Setup Infrastructure
1. Clone this repository:
   ```
   git clone https://github.com/zantac/cloud-migration.git
   cd cloud-migration/lift-and-shift
   ```

2. Initialize Terraform:
   ```
   cd terraform
   terraform init
   ```

3. Deploy the infrastructure:
   ```
   terraform apply -var-file=prod.tfvars
   ```

### Configure Applications
Once the infrastructure is deployed, use Ansible to configure the applications:

```
cd ../ansible
ansible-playbook -i inventory/aws_ec2.yml playbooks/webserver.yml
```

## Key Features

### Auto Scaling
The infrastructure uses Auto Scaling Groups to automatically adjust capacity based on demand:
- Scale up during peak hours
- Scale down during off-hours
- Health checks ensure only healthy instances receive traffic

### High Availability
- Multiple Availability Zones deployment
- Load balancers distribute traffic across healthy instances
- RDS with Multi-AZ deployment for database resilience

### Security
- Security Groups restrict traffic to necessary ports
- IAM roles with least privilege principle
- Private subnets for application and database tiers
- Network ACLs for subnet-level security

### Monitoring
- CloudWatch for metrics and logging
- CloudWatch Alarms for alerting
- AWS CloudTrail for API auditing

## Modernization Roadmap
1. **Phase 1**: Direct migration (current phase)
2. **Phase 2**: Database optimization
3. **Phase 3**: Application containerization
4. **Phase 4**: Cloud-native service adoption


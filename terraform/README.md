# Video Service Infrastructure

This Terraform configuration manages the infrastructure for the video concatenation service.

## Prerequisites
- Docker (>= 20.10.0)
- Docker Compose V2
- Terraform (>= 1.0.0)
- AWS CLI
- curl

## Components
- S3 bucket for video storage
- SQS queue for job processing
- RDS PostgreSQL for job metadata
- ECS/Fargate for service deployment
- VPC with proper networking (dev/prod only)

## Structure
```
terraform/
├── environments/          # Environment-specific configurations
│   ├── local/            # Local development environment
│   │   ├── main.tf       # Resource definitions
│   │   ├── locals.tf     # Environment variables and tags
│   │   ├── providers.tf  # Provider configuration
│   │   ├── backend.tf    # State configuration
│   │   ├── variables.tf  # Input variables
│   │   ├── versions.tf   # Version constraints
│   │   └── outputs.tf    # Output definitions
│   └── dev/             # Development environment
│       ├── main.tf      # Resource definitions
│       ├── locals.tf    # Environment variables and tags
│       ├── providers.tf # Provider configuration
│       ├── backend.tf   # State configuration
│       ├── variables.tf # Input variables
│       ├── versions.tf  # Version constraints
│       └── outputs.tf   # Output definitions
└── modules/             # Reusable modules
    ├── database/       # RDS configuration
    ├── storage/        # S3 and SQS configuration
    └── compute/        # ECS/Fargate configuration TODO
```

## Local Development
1. Start the local infrastructure:
```bash
# Start LocalStack and PostgreSQL
docker compose -f docker-compose.api.yml up -d

# Or use the helper script
./scripts/local-infra.sh start
```

2. Configure dummy AWS credentials for LocalStack:
```bash
aws configure set aws_access_key_id "dummy"
aws configure set aws_secret_access_key "dummy"
aws configure set region "us-east-1"
```

3. Apply Terraform configuration:
```bash
cd environments/local
terraform init
terraform plan
terraform apply
```

4. Test the infrastructure:
```bash
# Check overall status
./scripts/local-infra.sh status

# Test S3
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket
aws --endpoint-url=http://localhost:4566 s3 cp README.md s3://test-bucket/
aws --endpoint-url=http://localhost:4566 s3 ls s3://test-bucket/

# Test SQS
aws --endpoint-url=http://localhost:4566 sqs list-queues
aws --endpoint-url=http://localhost:4566 sqs send-message \
    --queue-url http://localhost:4566/000000000000/local-video-jobs \
    --message-body "test message"
aws --endpoint-url=http://localhost:4566 sqs receive-message \
    --queue-url http://localhost:4566/000000000000/local-video-jobs

# Test PostgreSQL
# Show database version and connection info
psql -h localhost -U postgres -d video_jobs -c "SELECT version();"

# Default credentials: username=postgres, password=postgres
psql -h localhost -U postgres -d video_jobs -c "\dt"
```

5. Stop the infrastructure:
```bash
./scripts/local-infra.sh stop
```

## Development Environment
1. Assume the correct AWS role:
```bash
aws sts assume-role --role-arn "arn:aws:iam::ACCOUNT_ID:role/TerraformRole" --role-session-name "terraform"
```

2. Apply Terraform configuration:
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

3. Verify the infrastructure:
```bash
# Test S3 bucket
aws s3 ls s3://${prefix}-videos/

# Test SQS queue
aws sqs get-queue-attributes \
    --queue-url $(terraform output -raw sqs_queue_url) \
    --attribute-names All

# Test RDS connection
psql -h $(terraform output -raw database_endpoint) \
     -U $(terraform output -raw database_username) \
     -d video_jobs
```

## Security Notes
- Database credentials are managed via AWS Secrets Manager
- All sensitive variables are marked with `sensitive = true`
- Infrastructure uses private subnets where possible
- VPC Flow Logs enabled for network monitoring
- IAM roles follow least privilege principle

## Contribution Guidelines

### File Organization
1. **Keep Environments Consistent**
   - Each environment should have the same file structure
   - Use `locals.tf` for environment-specific values
   - Keep resource definitions in `main.tf`

2. **Module Usage**
   - Use official AWS modules when available
   - Pin module versions using `version = "~> X.Y"`
   - Document module inputs/outputs

3. **Variable Management**
   - Use `locals.tf` for environment-specific values
   - Use `variables.tf` for configurable inputs
   - Mark sensitive values with `sensitive = true`

### Best Practices
1. **State Management**
   - Use remote state for non-local environments
   - Enable state locking with DynamoDB
   - Use separate state files per environment

2. **Security**
   - Store secrets in AWS Secrets Manager
   - Use IAM roles with least privilege
   - Enable encryption at rest
   - Use security groups judiciously

3. **Naming Conventions**
   - Use `local.prefix` for resource naming
   - Follow `{prefix}-{resource}-{suffix}` pattern
   - Use consistent tagging via `local.tags`

4. **Code Quality**
   - Run `terraform fmt` before committing
   - Run `terraform validate` before PR
   - Update documentation when changing structure
   - Add meaningful comments for complex configurations

5. **Pull Requests**
   - Include `terraform plan` output
   - Update README if adding new components
   - Follow existing file structure
   - Test changes in local environment first
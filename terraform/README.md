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

## Structure
```
terraform/
├── modules/
│   └── storage/           # Core infrastructure module
├── environments/
│   ├── dev/              # Development environment
│   ├── local/            # Local development (LocalStack)
│   └── prod/             # Production environment (TBD)
├── backend.tf            # State configuration
├── providers.tf          # AWS provider config
├── variables.tf          # Root variables
└── versions.tf           # Version constraints
```

## Environment Variables
For local development:
- No AWS credentials needed (LocalStack uses dummy values)
- Database credentials are preset in docker-compose.local.yml

For AWS environments:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `TF_VAR_db_password`

## Local Development
1. Start the local infrastructure:
```bash
./scripts/local-infra.sh start
```

2. Verify the setup:
```bash
# Check service status
./scripts/local-infra.sh status

# Test AWS services
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 sqs list-queues

# Test database connection
psql -h localhost -U postgres -d video_jobs
```

3. Stop the infrastructure:
```bash
./scripts/local-infra.sh stop
```

## AWS Deployment
1. Initialize Terraform:
```bash
cd environments/dev
terraform init
```

2. Set required variables:
```bash
export TF_VAR_db_password="your-secure-password"
```

3. Apply configuration:
```bash
terraform apply
``` 
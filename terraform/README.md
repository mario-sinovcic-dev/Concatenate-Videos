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

## Local Development
1. Start the local infrastructure:
```bash
./scripts/local-infra.sh start
```

2. Configure dummy AWS credentials for LocalStack:
```bash
aws configure set aws_access_key_id "dummy"
aws configure set aws_secret_access_key "dummy"
aws configure set region "us-east-1"
```

3. Test the infrastructure:
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

4. Stop the infrastructure:
```bash
./scripts/local-infra.sh stop
```

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
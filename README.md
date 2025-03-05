# Video Concatenation Service

A service for concatenating video files using Node.js and AWS services.

## Prerequisites
### Development Tools
- Node.js (>= 18)
- npm (>= 9)
- Docker (>= 20.10.0)
- Docker Compose V2
- Make

### For Local Testing
- Terraform (>= 1.0.0)
- AWS CLI
- curl
- PostgreSQL client (psql)

## Running the Application

### Using Make (Recommended)
```bash
# Info on all make targets
make help

# Run tests
make test

# Install, build and start API and localstack
make setup

# Just start the API service
make start-api

# Stop the API service
make stop-api

# Stop the localstack service
make stop-localstack 
```

The API will run on port 8000.

### Local OS Setup (Alternative)
1. Install OS-level dependencies:
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y ffmpeg

# CentOS/RHEL
sudo yum install -y ffmpeg
```

2. Install dependencies:
```bash
npm install
```

3. Start the application:
```bash
npm start
```

## Project Structure
- `/src` - Application source code
- `/tests` - Test files and configurations
- `/terraform` - Infrastructure as Code
- `/scripts` - Utility scripts
- `Makefile` - Development workflow automation

## Documentation
- [Infrastructure Setup](./terraform/README.md)
- [Testing Guide](./test/README.md)
- API Doco - TODO via swagger or other

## API Call Flow
```
POST /jobs
{
    "sourceVideoUrls": ["<url to mp4>", "<url to another mp4>"],
    "destination": {
        "directory": "<local path of directory that'll store merged file>"
    }
}
```

returns
```
{
    "id": "<job id>"
    "status": "<url to status of job>"
}
```

```
GET /job/{jobId}/status
```

returns
```
{
    "status": "pending"
}
```

## In Progress
### Prosed Architecture vs Existing Architecture

- currently the system design looks like first diagram [see original diagram for more info.](./architecture-overview.png)
- looking to move away from this and transition to the architecture below, need to implement repository and calls to infra from API (S3, SQS, Postgres, etc.)

__Current Architecture__
```
API -> Controllers -> Domain -> Repository -> In-Memory
                        |           |
                        v           v
                     ffmpeg    local file system
                        ^
                        |
              Background Job Processor
```

__Proposed New Architecture__
```
API -> Controllers -> Domain -> Repository -> PostgreSQL (RDS)
                        |           |
                        v           v
                     ffmpeg    S3 Bucket
                        ^
                        |
                    SQS Queue
                        ^
                        |
              Background Job Processor
```
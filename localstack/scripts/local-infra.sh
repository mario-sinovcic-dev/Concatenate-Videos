#!/bin/bash
set -e

# Set default IMAGE_TAG if not provided
export IMAGE_TAG=${IMAGE_TAG:-latest}

# Update paths relative to scripts directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCALSTACK_DIR="$SCRIPT_DIR/.."
PROJECT_ROOT="$LOCALSTACK_DIR/.."

function wait_for_localstack() {
    echo "Waiting for LocalStack to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Checking LocalStack health (attempt $attempt/$max_attempts)..."
        local health_output
        
        # Try to get health status, continue if curl fails
        if ! health_output=$(curl -s -f http://localhost:4566/_localstack/health 2>/dev/null); then
            echo "LocalStack not ready yet (connection failed)... waiting"
            sleep 2
            attempt=$((attempt + 1))
            continue
        fi

        # Check if S3 is available
        if echo "$health_output" | jq -e '.services.s3 == "available"' > /dev/null 2>&1; then
            echo "LocalStack is ready! (S3 service is available)"
            return 0
        fi
        
        echo "LocalStack not ready yet... (S3 service not available)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "LocalStack failed to start after $max_attempts attempts"
    exit 1
}

function setup_aws_local() {
    echo "Configuring AWS CLI for LocalStack..."
    aws configure set aws_access_key_id "test" --profile localstack
    aws configure set aws_secret_access_key "test" --profile localstack
    aws configure set region "us-east-1" --profile localstack
    aws configure set output "json" --profile localstack
    export AWS_PROFILE=localstack
    export AWS_DEFAULT_REGION=us-east-1
}

function setup_terraform() {
    echo "Setting up Terraform for LocalStack..."
    cd "$PROJECT_ROOT/terraform/environments/local"
    
    # Configure Terraform environment variables
    export AWS_ACCESS_KEY_ID="test"
    export AWS_SECRET_ACCESS_KEY="test"
    export AWS_DEFAULT_REGION="us-east-1"
    
    # Initialize and apply Terraform
    echo "Initializing Terraform..."
    terraform init
    
    echo "Planning Terraform changes..."
    terraform plan
    
    echo "Applying Terraform changes..."
    terraform apply -auto-approve
    
    cd - > /dev/null
}

case "$1" in
    start)
        echo "Starting local infrastructure..."
        cd "$LOCALSTACK_DIR"
        docker compose --profile infra up -d
        wait_for_localstack
        setup_aws_local
        setup_terraform
        echo "Local infrastructure is ready!"
        ;;
    
    stop)
        echo "Stopping local infrastructure..."
        cd "$LOCALSTACK_DIR"
        docker compose --profile infra down
        echo "Local infrastructure stopped"
        ;;
    
    status)
        echo "Checking LocalStack status..."
        curl -s http://localhost:4566/_localstack/health | jq .
        echo -e "\nChecking Terraform state..."
        cd "$PROJECT_ROOT/terraform/environments/local" && terraform show
        ;;
    
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;

    destroy)
        echo "Destroying local infrastructure..."
        cd "$PROJECT_ROOT/terraform/environments/local"
        terraform destroy -auto-approve
        cd - > /dev/null
        $0 stop
        ;;

    logs)
        echo "Showing LocalStack logs..."
        cd "$LOCALSTACK_DIR"
        docker compose --profile infra logs -f localstack
        ;;

    *)
        echo "Usage: $0 {start|stop|status|restart|destroy|logs}"
        echo
        echo "Commands:"
        echo "  start    - Start LocalStack and initialize infrastructure"
        echo "  stop     - Stop LocalStack"
        echo "  status   - Show LocalStack and Terraform status"
        echo "  restart  - Restart LocalStack"
        echo "  destroy  - Destroy infrastructure and stop LocalStack"
        echo "  logs     - Show LocalStack logs"
        exit 1
        ;;
esac

exit 0 
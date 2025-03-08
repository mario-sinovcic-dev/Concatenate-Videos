#!/bin/bash

# Ensure script fails on any error
set -e

# TODO - this bash script should be replaced with something that can run on any OS

# Function to check if LocalStack is ready
wait_for_localstack() {
    echo "Waiting for LocalStack to be ready..."
    while ! curl -s http://localhost:4566/_localstack/health | grep -q '"s3":"running"'; do
        sleep 2
    done
    echo "LocalStack is ready!"
}

# Function to initialize and apply Terraform
apply_terraform() {
    cd terraform/environments/local
    terraform init
    terraform apply -auto-approve
    cd ../../..
}

case "$1" in
    "start")
        # Start LocalStack and PostgreSQL
        docker compose -f docker-compose.localstack.yml up -d
        wait_for_localstack
        apply_terraform
        echo "Local infrastructure is ready!"
        ;;
    "stop")
        # Stop and clean up
        docker compose -f docker-compose.localstack.yml down
        echo "Local infrastructure stopped."
        ;;
    "status")
        # Check services status
        echo "LocalStack health check:"
        curl -s http://localhost:4566/_localstack/health
        echo -e "\n\nPostgreSQL check:"
        docker compose -f docker-compose.localstack.yml ps postgres
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac 
terraform {
  backend "s3" {
    bucket         = "video-processor-terraform-state"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    
    # Use role assumption for backend operations
    role_arn       = "arn:aws:iam::ACCOUNT_ID:role/TerraformBackendRole"
  }
} 
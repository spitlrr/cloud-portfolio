# 1. Define the Provider (AWS)
provider "aws" {
  region = "us-east-1"
}

# 2. Create a unique S3 Bucket for your files
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "beginner-devops-portfolio-2026"
}
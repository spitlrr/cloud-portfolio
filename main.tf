provider "aws" {
  region = "us-east-1"
}

# 1. The Bucket
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "beginner-devops-portfolio-2026"
}

# 1a. Enable Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.portfolio_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 1b. Explicitly Block Public Access
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 1c. Accept risk trade-off (using Customer Managed Key (CMK) costs $)
# trivy:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "YOUR_UNIQUE_BUCKET_NAME_HERE"
}

# 1d. Accept risk trade-off (using Web Application Firewall (WAF) costs $)
# trivy:ignore:aws-cloudfront-enable-waf
resource "aws_cloudfront_distribution" "s3_distribution" {
  # ... existing code ...
}

# 2. The OIDC Provider (Trust GitHub)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 3. The Role GitHub will use
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:spitlrr/cloud-portfolio:*"
          }
        }
      }
    ]
  })
}

# 4. Attach Permissions
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 5. The Output
output "role_arn" {
  value = aws_iam_role.github_actions_role.arn
}

# 1. Create the Origin Access Control
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-portfolio-oac"
  description                       = "OAC for Portfolio S3 Bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 2. Create the CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.portfolio_bucket.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https" # Security: Force Encryption
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # This is required even if you aren't restricting by country
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # For now, we use the default CloudFront certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# 3. Output the URL so you can find your site
output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

# This policy allows CloudFront to reach into the bucket
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.portfolio_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.portfolio_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}
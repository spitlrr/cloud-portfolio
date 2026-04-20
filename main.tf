provider "aws" {
  region = "us-east-1"
}

# 1. The Bucket
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "beginner-devops-portfolio-2026" # Must be lowercase, no spaces
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
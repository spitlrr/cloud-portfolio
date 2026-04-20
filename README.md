# Project Architecture Overview

The infrastructure of this project utilizes a CloudFront-to-S3 design protected by Origin Access Control (OAC). This ensures that the S3 bucket remains private and that all traffic is forced through the Content Delivery Network (CDN) for global distribution and encryption in transit.

## Security Implementation Highlights

**Identity Federation:** This pipeline uses OpenID Connect (OIDC) to establish a short-lived, passwordless trust relationship between GitHub Actions and AWS, eliminating the need for long-lived IAM keys.

**Infrastructure as Code (IaC) Auditing:** Every push triggers a **Trivy** scan of the Terraform configuration to identify misconfigurations _before_ deployment.

**Container Hardening:** The Python-based security API is built on an **Alpine Linux** base image. The build process includes an automated purge of vulnerable metadata and build tools to minimize the attack surface.

**Least Privilege:** All S3 bucket policies and IAM roles are scoped strictly to the resources required for deployment, preventing unauthorized lateral movement.

## Risk Management & Decision Log

A critical component of this documentation is the transparency regarding accepted risks. For this specific implementation, certain enterprise features (AWS WAF and Customer Managed Keys) were omitted to maintain a zero-cost footprint. These decisions are formally documented in the project's .trivyignore file to maintain a clear audit trail for security reviews.

## Future Roadmap

**Dynamic Compute:** Transitioning the hardened Python container from local execution to Amazon ECS.

**Database Integration:** Implementing an AWS Lambda-backed visitor counter.

**Advanced Monitoring:** Integrating CloudWatch Alarms for real-time traffic observability.

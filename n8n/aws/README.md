# n8n on AWS Starter Repo

This starter repo gives you three things:

1. **Terraform** to provision AWS infrastructure for n8n on ECS Fargate.
2. **Repository files** to build a custom n8n container image.
3. **GitHub Actions** to push that image to ECR and deploy it to ECS.

## Architecture

The Terraform in this repo creates:

- VPC with public and private subnets
- Internet Gateway and NAT Gateway
- Application Load Balancer with HTTP to HTTPS redirect
- ECS cluster, task definition, and Fargate service
- Amazon ECR repository
- CloudWatch log group
- RDS PostgreSQL instance
- Secrets Manager secrets for the DB password and n8n encryption key
- GitHub OIDC provider and an IAM role for GitHub Actions deployments

## Repo layout

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml
├── app/
│   └── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   └── versions.tf
├── .dockerignore
├── .gitignore
└── README.md
```

## Prerequisites

Before you apply Terraform, you should already have:

- an AWS account
- a public DNS record such as `n8n.example.com`
- an ACM certificate in the same region as the ALB
- Terraform installed locally
- a GitHub repository to store this code

## 1. Create the infrastructure

Copy the example variables file:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set at least:

- `domain_name`
- `certificate_arn`
- `github_owner`
- `github_repo`
- `github_branch`

Then deploy:

```bash
terraform init
terraform plan
terraform apply
```

## 2. Point DNS to the ALB

After `terraform apply`, grab the output:

```bash
terraform output alb_dns_name
```

Create a CNAME or Route 53 alias from your public hostname to the ALB.

## 3. Add GitHub repository settings

After the Terraform apply finishes, save these outputs:

```bash
terraform output ecr_repository_url
terraform output ecs_cluster_name
terraform output ecs_service_name
terraform output ecs_task_family
terraform output github_actions_role_arn
```

In GitHub, add the following **repository variables** under **Settings → Secrets and variables → Actions → Variables**:

- `AWS_REGION`
- `ECR_REPOSITORY`  
  Use the repository name only, for example `n8n-prod-n8n`
- `ECS_CLUSTER`
- `ECS_SERVICE`
- `ECS_TASK_FAMILY`

Add this **repository secret** under **Settings → Secrets and variables → Actions → Secrets**:

- `AWS_ROLE_ARN`  
  Set this to the `github_actions_role_arn` Terraform output.

## 4. Push to main to deploy

The workflow in `.github/workflows/deploy.yml` triggers on pushes to `main` when files under `app/` change, and it can also be run manually.

The deploy flow does this:

1. uses GitHub OIDC to assume the AWS deploy role
2. logs into Amazon ECR
3. builds the image from `app/Dockerfile`
4. pushes the image to ECR
5. fetches the current ECS task definition
6. swaps in the new image
7. updates the ECS service

## Notes about n8n configuration

The ECS task definition created by Terraform sets these important values:

- `DB_TYPE=postgresdb`
- `WEBHOOK_URL=https://<your-domain>/`
- `N8N_PROXY_HOPS=1`
- `N8N_ENCRYPTION_KEY` from Secrets Manager

That gives you a working baseline for running n8n behind an ALB with PostgreSQL.

## Common follow-up changes

You may want to add these next:

- Route 53 DNS records in Terraform
- WAF on the ALB
- ElastiCache Redis and n8n queue mode
- ECS autoscaling
- RDS Multi-AZ for higher availability
- S3 for binary data storage
- VPC endpoints to reduce NAT traffic costs

## Important caveats

- This starter uses **one NAT Gateway** to keep the design simpler. That is fine for a starter setup, but it is a single point of failure across AZs.
- The RDS instance is a small default size intended for starting out, not large production throughput.
- The ALB assumes you already have an ACM certificate.
- Terraform does not manage your DNS record in this starter.
- The ECS service starts with the upstream stable n8n image. After the first GitHub Actions deploy, your own ECR image becomes the active image.

## Destroying the stack

```bash
cd terraform
terraform destroy
```

## Where to customize

- Change `app/Dockerfile` if you want to add packages or community nodes.
- Change `terraform/variables.tf` and `terraform.tfvars` to size the environment differently.
- Change `.github/workflows/deploy.yml` if you want separate staging and production deployments.

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Short name used in resource naming"
  type        = string
  default     = "n8n"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Two public subnets for the ALB"
  type        = list(string)
  default     = ["10.42.0.0/24", "10.42.1.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Two private subnets for ECS tasks"
  type        = list(string)
  default     = ["10.42.10.0/24", "10.42.11.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "Two private subnets for RDS"
  type        = list(string)
  default     = ["10.42.20.0/24", "10.42.21.0/24"]
}

variable "availability_zones" {
  description = "Two AZs to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the ALB HTTPS listener"
  type        = string
}

variable "domain_name" {
  description = "Public hostname for n8n, for example n8n.example.com"
  type        = string
}

variable "github_owner" {
  description = "GitHub org or user that owns the repo"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to deploy through OIDC"
  type        = string
  default     = "main"
}

variable "container_port" {
  description = "n8n listens on this container port"
  type        = number
  default     = 5678
}

variable "ecs_cpu" {
  description = "Fargate CPU units for n8n"
  type        = number
  default     = 1024
}

variable "ecs_memory" {
  description = "Fargate memory for n8n in MiB"
  type        = number
  default     = 2048
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "rds_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "rds_allocated_storage" {
  description = "Initial storage for PostgreSQL"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Autoscaling limit for PostgreSQL storage"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "n8n database name"
  type        = string
  default     = "n8n"
}

variable "db_username" {
  description = "n8n database username"
  type        = string
  default     = "n8n"
}

variable "n8n_timezone" {
  description = "Default timezone inside the container"
  type        = string
  default     = "Europe/Dublin"
}

variable "n8n_image" {
  description = "Initial container image used by Terraform before CI/CD updates it"
  type        = string
  default     = "docker.n8n.io/n8nio/n8n:stable"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the RDS instance"
  type        = bool
  default     = false
}

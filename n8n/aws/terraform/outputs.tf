output "alb_dns_name" {
  description = "DNS name of the public application load balancer"
  value       = aws_lb.this.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL used by GitHub Actions"
  value       = aws_ecr_repository.this.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "ecs_task_family" {
  description = "ECS task definition family"
  value       = aws_ecs_task_definition.this.family
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub OIDC deployments"
  value       = aws_iam_role.github_actions.arn
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.this.address
}

output "secrets_manager_db_secret_arn" {
  description = "Secret ARN for the generated database password"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "secrets_manager_n8n_encryption_key_arn" {
  description = "Secret ARN for the generated n8n encryption key"
  value       = aws_secretsmanager_secret.n8n_encryption_key.arn
}

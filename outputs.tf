output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.plausible.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.plausible.name
}

output "ecs_capacity_provider_name" {
  description = "Name of the EC2 capacity provider"
  value       = aws_ecs_capacity_provider.plausible.name
}

variable "sg_private_default" {
  type        = string
  description = "Security group ID for private default access"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "ecs_cluster" {
  type        = string
  description = "ECS cluster ID"
}

variable "capacity_provider" {
  type        = string
  description = "ECS capacity provider name"
}

variable "subnets" {
  type        = list(string)
  description = "Subnet IDs for the ECS service"
}

variable "plausible_version" {
  type        = string
  description = "Plausible CE version to deploy"
}

variable "domain_name" {
  type        = string
  description = "FQDN for the Plausible instance"
}

variable "lb_listener_arn" {
  type        = string
  description = "ARN of the ALB HTTPS listener"
}

variable "lb_listener_dns" {
  type        = string
  description = "DNS name of the ALB"
}

variable "lb_listener_zone_id" {
  type        = string
  description = "Route53 zone ID of the ALB"
}

variable "route53_zone" {
  type        = string
  description = "Route53 hosted zone ID"
}

variable "sg_https_from_any" {
  type        = string
  description = "Security group ID for the load balancer"
}

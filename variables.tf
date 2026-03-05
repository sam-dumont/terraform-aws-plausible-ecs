variable "plausible_version" {
  type        = string
  description = "Plausible Community Edition version"
  default     = "v2.1.4"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the Plausible instance (e.g. plausible.example.com)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ECS cluster will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the ECS tasks"
}

variable "lb_listener_arn" {
  type        = string
  description = "ARN of the HTTPS listener on the ALB"
}

variable "lb_dns_name" {
  type        = string
  description = "DNS name of the ALB (for Route53 alias)"
}

variable "lb_zone_id" {
  type        = string
  description = "Route53 zone ID of the ALB (for alias record)"
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for DNS records"
}

variable "sg_default_id" {
  type        = string
  description = "Default security group ID for private resources"
}

variable "sg_lb_id" {
  type        = string
  description = "Security group ID attached to the load balancer"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the EC2 SSH key pair for ECS instances"
  default     = ""
}

# terraform-aws-plausible-ecs

Terraform module to deploy [Plausible Analytics Community Edition](https://plausible.io/) on AWS ECS.

Runs Plausible behind an existing ALB using a hybrid capacity strategy: Fargate Spot as default, with an EC2 Auto Scaling Group (ARM-based `t4g.small` spot instances) as fallback. ECS handles capacity provider management automatically.

I ran this in production for about 2 years on a personal AWS account. The original deployment had hardcoded values and data sources tied to a specific VPC: this version replaces all of that with input variables so you can plug it into your own infra.

## Architecture

```
ALB (existing) ──> Target Group (:8000) ──> ECS Service
                                              │
                                    ┌─────────┴─────────┐
                                    │  Capacity Strategy │
                                    │  1. FARGATE_SPOT   │
                                    │  2. EC2 (t4g.small)│
                                    └────────────────────┘
                                              │
                                    ┌─────────┴─────────┐
                                    │  Plausible CE      │
                                    │  (awsvpc network)  │
                                    └────────────────────┘
```

ACM certificate provisioning and DNS validation are handled via Route53.

## Usage

```hcl
provider "aws" {
  region = "eu-west-1"
}

module "plausible" {
  source  = "sam-dumont/plausible-ecs/aws"
  version = "~> 0.1"

  plausible_version  = "v2.1.4"
  domain_name        = "plausible.example.com"
  vpc_id             = "vpc-0123456789abcdef0"
  private_subnet_ids = ["subnet-aaa", "subnet-bbb"]
  lb_listener_arn    = aws_lb_listener.https.arn
  lb_dns_name        = aws_lb.main.dns_name
  lb_zone_id         = aws_lb.main.zone_id
  route53_zone_id    = aws_route53_zone.main.zone_id
  sg_default_id      = aws_security_group.private.id
  sg_lb_id           = aws_security_group.lb.id
}
```

## Prerequisites

You need these already deployed:

- A VPC with private subnets
- An Application Load Balancer with an HTTPS listener (port 443)
- A Route53 hosted zone for your domain
- Security groups for private resources and the ALB

All of these are passed as input variables, not created by this module.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| [aws](https://registry.terraform.io/providers/hashicorp/aws/latest) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

### Root module

| Name | Type |
|------|------|
| `aws_ecs_cluster.plausible` | resource |
| `aws_ecs_cluster_capacity_providers.plausible` | resource |
| `aws_ecs_capacity_provider.plausible` | resource |
| `aws_autoscaling_group.plausible` | resource |
| `aws_launch_template.plausible` | resource |
| `aws_cloudwatch_log_group.plausible` | resource |
| `aws_iam_role.ecs_service_role` | resource |
| `aws_iam_role.plausible` | resource |
| `aws_iam_instance_profile.plausible` | resource |
| `aws_iam_role_policy_attachment.service_role` | resource |
| `aws_iam_role_policy_attachment.plausible_default` | resource |
| `aws_iam_role_policy_attachment.plausible_ssm` | resource |
| `aws_caller_identity.current` | data source |
| `aws_region.current` | data source |
| `aws_ssm_parameter.arm_al2023` | data source |
| `cloudinit_config.plausible` | data source |
| `aws_iam_policy_document.ecs_service_role_policy` | data source |
| `aws_iam_policy_document.ecs_task_role_policy` | data source |

### Submodule: `modules/plausible`

| Name | Type |
|------|------|
| `aws_ecs_task_definition.plausible` | resource |
| `aws_ecs_service.plausible` | resource |
| `aws_lb_target_group.plausible` | resource |
| `aws_lb_listener_rule.plausible` | resource |
| `aws_acm_certificate.plausible` | resource |
| `aws_acm_certificate_validation.cert` | resource |
| `aws_lb_listener_certificate.plausible` | resource |
| `aws_route53_record.plausible` | resource |
| `aws_route53_record.validation` | resource |
| `aws_security_group.plausible` | resource |
| `aws_security_group_rule.plausible_port` | resource |
| `aws_security_group_rule.lb_port` | resource |
| `aws_cloudwatch_log_group.ecs_plausible` | resource |
| `aws_iam_role.plausible_task_role` | resource |
| `aws_iam_role.plausible` | resource |
| `aws_iam_instance_profile.plausible` | resource |
| `aws_iam_role_policy.allow_create_log_groups` | resource |
| `aws_iam_role_policy_attachment.plausible_task_role` | resource |
| `aws_iam_role_policy_attachment.ecs` | resource |
| `aws_iam_role_policy_attachment.plausible_instance_ssm` | resource |
| `aws_region.current` | data source |
| `aws_iam_policy_document.plausible_task_role_policy` | data source |
| `aws_iam_policy_document.plausible_allow_create_log_groups` | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `plausible_version` | Plausible Community Edition version | `string` | `"v2.1.4"` | no |
| `domain_name` | FQDN for the Plausible instance (e.g. `plausible.example.com`) | `string` | n/a | **yes** |
| `vpc_id` | VPC ID where the ECS cluster will be deployed | `string` | n/a | **yes** |
| `private_subnet_ids` | List of private subnet IDs for the ECS tasks | `list(string)` | n/a | **yes** |
| `lb_listener_arn` | ARN of the HTTPS listener on the ALB | `string` | n/a | **yes** |
| `lb_dns_name` | DNS name of the ALB (for Route53 alias) | `string` | n/a | **yes** |
| `lb_zone_id` | Route53 zone ID of the ALB (for alias record) | `string` | n/a | **yes** |
| `route53_zone_id` | Route53 hosted zone ID for DNS records | `string` | n/a | **yes** |
| `sg_default_id` | Default security group ID for private resources | `string` | n/a | **yes** |
| `sg_lb_id` | Security group ID attached to the load balancer | `string` | n/a | **yes** |
| `ssh_key_name` | Name of the EC2 SSH key pair for ECS instances | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| `ecs_cluster_id` | ID of the ECS cluster |
| `ecs_cluster_name` | Name of the ECS cluster |
| `ecs_capacity_provider_name` | Name of the EC2 capacity provider |

## Cost

The default setup uses `t4g.small` spot instances (ARM), which run at about $0.006/hour in eu-west-1. With Fargate Spot as the primary capacity provider, that's roughly $5-10/month for a low-traffic Plausible instance. The ASG scales to 0 when there's no work.

## License

MIT

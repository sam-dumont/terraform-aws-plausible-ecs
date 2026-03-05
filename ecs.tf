resource "aws_ecs_cluster" "plausible" {
  name = "plausible"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.plausible.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "plausible" {
  name = "plausible"
}

resource "aws_ecs_cluster_capacity_providers" "plausible" {
  cluster_name = aws_ecs_cluster.plausible.name

  capacity_providers = [
    "FARGATE_SPOT", aws_ecs_capacity_provider.plausible.name
  ]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_capacity_provider" "plausible" {
  name = "plausible"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.plausible.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_autoscaling_group" "plausible" {
  name_prefix           = "plausible_"
  max_size              = 1
  min_size              = 0
  vpc_zone_identifier   = var.private_subnet_ids
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.plausible.id
    version = aws_launch_template.plausible.latest_version
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = ""
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "plausible"
  }
}

data "cloudinit_config" "plausible" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<EOT
#!/bin/bash
export AWS_DEFAULT_REGION=${data.aws_region.current.name}
export AWS_REGION=${data.aws_region.current.name}

echo ECS_CLUSTER="plausible" >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config
echo "ECS_DISABLE_DOCKER_HEALTH_CHECK=true" >> /etc/ecs/ecs.config
EOT
  }
}

data "aws_ssm_parameter" "arm_al2023" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended"
}

resource "aws_launch_template" "plausible" {
  name_prefix            = "ecs_arm_node_"
  image_id               = jsondecode(data.aws_ssm_parameter.arm_al2023.value)["image_id"]
  instance_type          = "t4g.small"
  vpc_security_group_ids = [var.sg_default_id]
  user_data              = data.cloudinit_config.plausible.rendered
  update_default_version = true
  key_name               = var.ssh_key_name != "" ? var.ssh_key_name : null

  private_dns_name_options {
    enable_resource_name_dns_a_record = false
  }

  network_interfaces {
  }

  credit_specification {
    cpu_credits = "standard"
  }

  instance_market_options {
    market_type = "spot"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.plausible.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
  }

  tags = {
    Name = "plausible"
  }
}

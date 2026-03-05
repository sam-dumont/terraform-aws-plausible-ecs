resource "aws_ecs_task_definition" "plausible" {
  family             = "plausible"
  network_mode       = "awsvpc"
  cpu                = 4096
  memory             = 15000
  execution_role_arn = aws_iam_role.plausible_task_role.arn
  task_role_arn      = aws_iam_role.plausible.arn

  container_definitions = jsonencode([
    {
      name  = "plausible"
      image = "ghcr.io/plausible/community-edition:${var.plausible_version}"
      environment = [
        {
          "name" : "plausible_HOST",
          "value" : "0.0.0.0"
        }
      ],
      resourceRequirements = [
        {
          "type" : "GPU",
          "value" : "1"
        }
      ],
      logConfiguration = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_plausible.name,
          "awslogs-region"        = data.aws_region.current.name,
          "awslogs-stream-prefix" = "ecs/plausible"
        }
      }
      networkMode = "awsvpc"
      essential   = true
      portMappings = [
        {
          containerPort = 3003
          hostPort      = 3003
        }
      ]
    }
  ])
}

data "aws_region" "current" {}

resource "aws_ecs_service" "plausible" {
  name                               = "plausible"
  cluster                            = var.ecs_cluster
  task_definition                    = aws_ecs_task_definition.plausible.arn
  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.capacity_provider
  }

  network_configuration {
    security_groups = [aws_security_group.plausible.id, var.sg_private_default]
    subnets         = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.plausible.arn
    container_name   = "plausible"
    container_port   = 3003
  }
}

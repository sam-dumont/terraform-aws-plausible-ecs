resource "aws_lb_target_group" "plausible" {
  name        = "plausible"
  target_type = "ip"
  port        = "8000"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    port                = 8000
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200-399"
  }
}

resource "aws_lb_listener_rule" "plausible" {
  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plausible.arn
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

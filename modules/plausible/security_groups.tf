resource "aws_security_group" "plausible" {
  name        = "plausible_inbound"
  description = "Allow plausible inbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "plausible inbound"
  }
}

resource "aws_security_group_rule" "plausible_port" {
  description              = "Allow traffic from LB to Plausible containers"
  from_port                = 8000
  protocol                 = "tcp"
  security_group_id        = var.sg_https_from_any
  source_security_group_id = aws_security_group.plausible.id
  to_port                  = 8000
  type                     = "egress"
}

resource "aws_security_group_rule" "lb_port" {
  description              = "Allow inbound traffic from LB"
  from_port                = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.plausible.id
  source_security_group_id = var.sg_https_from_any
  to_port                  = 8000
  type                     = "ingress"
}

module "plausible" {
  source             = "./modules/plausible"
  ecs_cluster        = aws_ecs_cluster.plausible.id
  capacity_provider  = aws_ecs_capacity_provider.plausible.name
  subnets            = var.private_subnet_ids
  sg_private_default = var.sg_default_id
  vpc_id             = var.vpc_id
  plausible_version  = var.plausible_version
  domain_name        = var.domain_name
  lb_listener_arn    = var.lb_listener_arn
  lb_listener_dns    = var.lb_dns_name
  lb_listener_zone_id = var.lb_zone_id
  route53_zone       = var.route53_zone_id
  sg_https_from_any  = var.sg_lb_id
}

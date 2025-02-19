resource "aws_security_group" "main" {
  name        = "Core ${var.service}"
  description = "${var.service} Security Group for Core"
  vpc_id      = var.network.vpc
}

resource "aws_security_group_rule" "allow_ingress_main" {
  description              = "Allow loadbalancer to access ${var.service}"
  type                     = "ingress"
  to_port                  = var.network.port
  protocol                 = "tcp"
  from_port                = var.network.port
  security_group_id        = aws_security_group.main.id
  source_security_group_id = var.loadbalancer.security_group
}

resource "aws_security_group_rule" "main_egress_traffic" {
  description       = "Allows egress traffic to outside world"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.main.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_egress_rds" {
  count                    = length(var.rds.security_groups)
  description              = "Allow egress from ${var.service} to RDS"
  type                     = "egress"
  to_port                  = 3306
  protocol                 = "tcp"
  from_port                = 3306
  security_group_id        = aws_security_group.main.id
  source_security_group_id = var.rds.security_groups[count.index]
}

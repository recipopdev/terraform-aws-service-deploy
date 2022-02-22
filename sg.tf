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
  description       = "Allows Egress traffic to outside world"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  security_group_id = aws_security_group.main.id
  cidr_blocks       = ["0.0.0.0/0"]
}
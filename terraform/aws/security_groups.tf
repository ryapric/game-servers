resource "aws_security_group" "main" {
  description = "Various game server ingress rules"
  name        = "game-servers"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  description       = "Allow all"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "ping" {
  type              = "ingress"
  description       = "Ping from everywhere"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  description       = "SSH from deployer IP"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.my_ip.body)}/32"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "games" {
  count = length(local.game_ports)

  type              = "ingress"
  description       = local.game_ports[count.index].name
  from_port         = local.game_ports[count.index].port
  to_port           = local.game_ports[count.index].port
  protocol          = local.game_ports[count.index].protocol
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.main.id
}

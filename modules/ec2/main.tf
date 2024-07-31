resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.bastion_nodes
  }

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = "TCP"
      cidr_blocks = ingress.value["cidr"]
      description = ingress.key
    }
  }

  tags = {
    Name = "${var.name}-${var.env}-sg"
  }
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.rhel9.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = var.subnet_ids[0]

  tags = {
    Name = "${var.name}-${var.env}"
  }
}


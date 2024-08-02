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

  root_block_device {
    volume_size = "30"
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.name}-${var.env}"
  }
}

resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = "${var.name}-${var.env}"
  type    = "A"
  ttl     = 10
  records = [aws_instance.main.private_ip]
}

resource "null_resource" "ansible" {
  depends_on = [aws_route53_record.record]

  triggers = {
    ip = aws_instance.main.private_ip
  }

  provisioner "remote-exec" {
    connection {
      host     = aws_instance.main.private_ip
      user     = data.vault_generic_secret.ssh.data["username"]
      password = data.vault_generic_secret.ssh.data["password"]
    }

    inline = [
      "sudo set-prompt -skip-apply ${var.name}-${var.env}",
      "sudo dnf install docker -y",
      "sudo growpart /dev/nvme0n1 4",
      "lvextend -r -L +10G /dev/mapper/RootVG-varVol"
    ]

  }

}

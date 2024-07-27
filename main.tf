resource "aws_instance" "instances" {
  count                  = length(var.components)
  ami                    = data.aws_ami.rhel9.image_id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.sg.*.id[count.index]]

  tags = {
    Name = "${var.components[count.index]}-${var.env}"
  }
}


resource "aws_security_group" "sg" {
  count       = length(var.components)
  name        = "${var.components[count.index]}-${var.env}"
  description = "${var.components[count.index]}-${var.env}"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.components[count.index]}-${var.env}"
  }
}

resource "aws_route53_record" "record" {
  count   = length(var.components)
  zone_id = "Z007676254S94NU47MG"
  name    = "${var.components[count.index]}-${var.env}"
  type    = "A"
  ttl     = 10
  records = [aws_instance.instances.*.private_ip[count.index]]
}

resource "null_resource" "prompt" {
  count = length(var.components)

  provisioner "remote-exec" {
    connection {
      host     = aws_instance.instances.*.private_ip[count.index]
      user     = data.vault_generic_secret.ssh.data["username"]
      password = data.vault_generic_secret.ssh.data["password"]
    }

    inline = [
      "sudo set-prompt -skip-apply ${var.components[count.index]}-${var.env}",
      "sudo pip3.11 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/raghudevopsb79/roboshop-ansible -e env=${var.env} -e component=${var.components[count.index]} -e vault_token=${var.vault_token} main.yml"
    ]

  }

}

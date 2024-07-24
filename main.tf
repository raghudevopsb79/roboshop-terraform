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


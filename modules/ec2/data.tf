data "aws_ami" "rhel9" {
  most_recent = true
  name_regex  = "RHEL-9-DevOps-Practice"
  owners      = ["973714476881"]
}

data "vault_generic_secret" "ssh" {
  path = "common/ssh-creds"
}
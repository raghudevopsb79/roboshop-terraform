resource "aws_opensearch_domain" "main" {
  domain_name    = "${var.name}-${var.env}"
  engine_version = var.engine_version

  cluster_config {
    instance_type = var.instance_type
  }


  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = data.vault_generic_secret.opensearch.data["MASTER_USERNAME"]
      master_user_password = data.vault_generic_secret.opensearch.data["MASTER_PASSWORD"]
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  tags = {
    Domain = "${var.name}-${var.env}"
  }
}


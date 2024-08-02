env           = "dev"
bastion_nodes = ["172.31.23.77/32"]
zone_id       = "Z007676254S94NU47MG"


vpc = {
  main = {
    cidr               = "10.0.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
    subnets = {

      public = {
        cidr = ["10.0.0.0/24", "10.0.1.0/24"]
        igw  = true
      }

      web = {
        cidr = ["10.0.2.0/24", "10.0.3.0/24"]
        ngw  = true
      }

      app = {
        cidr = ["10.0.4.0/24", "10.0.5.0/24"]
        ngw  = true
      }

      db = {
        cidr = ["10.0.6.0/24", "10.0.7.0/24"]
        ngw  = true
      }

    }

    peering_vpcs = {
      tools = {
        id             = "vpc-0e93ff27d39f864b7"
        cidr           = "172.31.0.0/16"
        route_table_id = "rtb-0c956acbaf6b0f983"
      }
    }

  }
}

db_servers = {

  rabbitmq = {
    instance_type = "t3.small"
    ports = {
      rabbitmq = {
        port = 5672
        cidr = ["10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

  mysql = {
    instance_type = "t3.small"
    ports = {
      mysql = {
        port = 3306
        cidr = ["10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

  mongo = {
    instance_type = "t3.small"
    ports = {
      mongo = {
        port = 27017
        cidr = ["10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

  redis = {
    instance_type = "t3.small"
    ports = {
      redis = {
        port = 6379
        cidr = ["10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

}

app_servers = {

  catalogue = {
    instance_type = "t3.small"
    ports = {
      catalogue-app = {
        port = 8080
        cidr = ["10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

  user = {
    instance_type = "t3.small"
    ports = {
      user-app = {
        port = 8080
        cidr = ["10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

  cart = {
    instance_type = "t3.small"
    ports = {
      cart-app = {
        port = 8080
        cidr = ["10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

  shipping = {
    instance_type = "t3.small"
    ports = {
      shipping-app = {
        port = 8080
        cidr = ["10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

  payment = {
    instance_type = "t3.small"
    ports = {
      payment-app = {
        port = 8080
        cidr = ["10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24", "10.0.5.0/24"]
      }
    }
  }

}

web_servers = {

  frontend = {
    instance_type = "t3.small"
    ports = {
      frontend-app = {
        port = 80
        cidr = ["10.0.0.0/24", "10.0.1.0/24"]
      }
    }
  }

}

load_balancers = {

  frontend = {
    internal           = false
    load_balancer_type = "application"
  }

}

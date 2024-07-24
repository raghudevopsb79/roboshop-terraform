variable "components" {
  default = [
    "frontend",
    "catalogue",
    "user",
    "cart",
    "shipping",
    "payment",
    "dispatch",
    "mongo",
    "mysql",
    "rabbitmq",
    "redis"
  ]
}

variable "env" {
  default = "dev"
}

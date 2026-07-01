variable "project" {
  type    = string
  default = "roboshop"

}

variable "environment" {
  type    = string
  default = "dev"

}

variable "sg_names" {
  type = list(string)
  default = [
    "mongodb", "redis", "mysql", "rabbitmq",
    "catalogue", "user", "cart", "shipping", "payment",
    "frontend",
    "bastion",
    "frontend-alb", "backend-alb"

  ]

}


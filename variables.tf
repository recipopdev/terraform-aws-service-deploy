variable "service" {
  type = string
}

variable "cluster" {
  type = string
}

variable "container" {
  type = object({
    cpu         = number
    memory      = number
    image       = string
    health_path = string
    count       = number
    environment = list(map(string))
  })
}

variable "loadbalancer" {
  type = object({
    listener       = string
    security_group = string
    dns            = string
  })
}

variable "network" {
  type = object({
    vpc     = string
    subnets = list(string)
    port    = number
  })
}

variable "log_group" {
  type = string
}
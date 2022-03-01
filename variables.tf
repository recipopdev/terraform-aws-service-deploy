variable "service" {
  description = "The name of the service being deployed"
  type        = string
}

variable "cluster" {
  description = "The name of the cluster to deploy into"
  type        = string
}

variable "container" {
  description = "The details of the container that is being deployed"
  type        = object({
    cpu         = number
    memory      = number
    image       = string
    health_path = string
    count       = number
    environment = list(map(string))
    commands    = list(string)
  })
}

variable "loadbalancer" {
  description = "The loadbalancer the service will be attached to"
  type        = object({
    listener       = string
    security_group = string
    dns            = string
  })
}

variable "network" {
  description = "The network details for the swervice that is being deployed"
  type        = object({
    vpc     = string
    subnets = list(string)
    port    = number
  })
}

variable "log_group" {
  description = "The Log group that the service will write to"
  type        = string
}
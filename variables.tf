variable "service" {
  description = "The name of the service being deployed"
  type        = string
}

variable "cluster" {
  description = "The name of the cluster to deploy into"
  type        = string
}

variable "volume" {
  description = "The name of the volume that is used"
  type        = string
  default     = ""
}

variable "container" {
  description = "The details of the container that is being deployed"
  type = object({
    cpu         = number
    memory      = number
    image       = string
    count       = number
    environment = list(map(string))
    commands    = list(string)
    health_check = object({
      path         = string
      status_code  = string
      timeout      = string
      grace_period = string
    })
    mount_points = list(map(string))
  })
}

variable "rds" {
  description = "The security groups that belong to the RDS cluster"
  type = object({
    security_groups = list(string)
  })
  default = {
    security_groups = []
  }
}

variable "loadbalancer" {
  description = "The loadbalancer the service will be attached to"
  type = object({
    listener       = string
    security_group = string
    dns            = list(string)
  })
}

variable "network" {
  description = "The network details for the swervice that is being deployed"
  type = object({
    vpc     = string
    subnets = list(string)
    port    = number
  })
}

variable "log_group" {
  description = "The Log group that the service will write to"
  type        = string
}

variable "create_secret" {
  description = "Whether to create a secret and attach permissions to read it"
  type        = bool
  default     = false
}

variable "create_bucket" {
  description = "Whether to create a bucket and attach permissions to read it"
  type        = bool
  default     = false
}

variable "sidecar" {
  description = "Whether to enable service discovery of tasks"
  type = object({
    name         = string
    image        = string
    cpu          = number
    memory       = number
    environment  = list(map(string))
    mount_points = list(map(string))
  })
  default = {
    name         = ""
    image        = ""
    cpu          = 0
    memory       = 0
    environment  = [{}]
    mount_points = [{}]
  }
}

variable "windows_deployment" {
  description = "Whether to create a windows deployment"
  type        = bool
  default     = false
}

variable "scaling" {
  description = "Whether to enable scaling and the settings to apply if it is"
  type = object({
    enabled = bool
    minimum = number
    maximum = number
    cpu = object({
      threshold          = number
      scale_in_cooldown  = number
      scale_out_cooldown = number
    })
    memory = object({
      threshold          = number
      scale_in_cooldown  = number
      scale_out_cooldown = number
    })
  })
  default = {
    enabled = false
    minimum = 0
    maximum = 0
    cpu = {
      threshold          = 0
      scale_in_cooldown  = 0
      scale_out_cooldown = 0
    }
    memory = {
      threshold          = 0
      scale_in_cooldown  = 0
      scale_out_cooldown = 0
    }
  }
}

locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
}

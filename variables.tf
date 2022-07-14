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
  type = object({
    cpu          = number
    memory       = number
    image        = string
    count        = number
    environment  = list(map(string))
    commands     = list(string)
    health_check = object({
      path        = string
      status_code = string
      timeout     = string
    })
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

variable "service_discovery" {
  description = "Whether to enable service discovery of tasks"
  type = object({
    enabled = bool
    name    = string
    image   = string
  })
  default = {
    enabled = false
    name    = ""
    image   = ""
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
    service = string
    scale_up = object({
      bound = number
      cpu = object({
        evaluation_period = string
        period            = string
        threshold         = string
      })
      memory = object({
        evaluation_period = string
        period            = string
        threshold         = string
      })
    })
    scale_down = object({
      bound = number
      cpu = object({
        evaluation_period = string
        period            = string
        threshold         = string
      })
      memory = object({
        evaluation_period = string
        period            = string
        threshold         = string
      })
    })
  })
  default = {
    enabled = false
    service = ""
    scale_up = {
      bound = 0
      cpu = {
        evaluation_period = ""
        period            = ""
        threshold         = ""
      }
      memory = {
        evaluation_period = ""
        period            = ""
        threshold         = ""
      }
    }
    scale_down = {
      bound = 0
      cpu = {
        evaluation_period = ""
        period            = ""
        threshold         = ""
      }
      memory = {
        evaluation_period = ""
        period            = ""
        threshold         = ""
      }
    }
  }
}

locals {
  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
}

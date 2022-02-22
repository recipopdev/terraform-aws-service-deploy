# Terraform Service Deployment Module
Terraform module for deploying services into AWS Fargate

## Usage

```hcl-terraform
module "service" {
  source  = "recipopdev/service-deploy/aws"
  version = "0.0.1"

  service   = "example"
  cluster   = "example-cluster"
  log_group = "example-log-group"

  network = {
    vpc     = aws_vpc.example.id
    subnets = [aws_subnet.example.id]
    port    = 80
  }

  container = {
    cpu         = 1024
    memory      = 2048
    count       = 1
    image       = "${aws_ecr_repository.example.repository_url}:latest"
    environment = [
      {
        name  = "EXAMPLE_VARIABLE"
        value = "example_value"
      }
    ]
    health_path = "/"
  }

  loadbalancer = {
    listener       = aws_lb_listener.example.id
    security_group = aws_security_group.example.id
    dns            = aws_lb.example.dns_name
  }
}
```

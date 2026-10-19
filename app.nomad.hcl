job "hubspot-extraction-service" {
  datacenters = ["dc1"]
  type        = "service"

  group "api" {
    count = 1

    # Static port allocation matching Dockerfile.staging (5104)
    network {
      port "http" {
        static = 5104
      }
    }

    # Service registration with Consul & health check
    service {
      name     = "hubspot-extraction-service"
      port     = "http"
      provider = "consul"

      check {
        type     = "http"
        path     = "/scan/health"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "ghcr.io/${var.github_repository}:latest"
        ports = ["http"]
      }

      # Optional environment variables
      env {
        PORT               = "5104"
        FLASK_ENV          = "staging"
        MAX_WORKER_THREADS = "5"
      }

      # Resource constraints
      resources {
        cpu    = 500  # 500 MHz
        memory = 512  # 512 MB
      }
    }
  }
}

variable "github_repository" {
  type        = string
  description = "GitHub repository (owner/repo) for GHCR image path"
  default     = "kevindwitama/hubspot-company"
}

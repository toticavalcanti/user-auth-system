terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "meu_cluster" {
  name    = "meu-cluster"
  region  = "nyc1"
  version = "1.31.1-do.2"

  node_pool {
    name       = "default-pool"
    size       = "s-1vcpu-2gb"
    node_count = 2
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "do-nyc1-meu-cluster"
}

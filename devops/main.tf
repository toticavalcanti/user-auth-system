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

# Criar o cluster Kubernetes
resource "digitalocean_kubernetes_cluster" "meu_cluster" {
  name    = "meu-cluster"
  region  = "nyc1"
  version = "1.31.1-do.0"  # Certifique-se de usar uma versão válida

  node_pool {
    name       = "default-pool"
    size       = "s-1vcpu-2gb"
    node_count = 2
  }
}

# Output para o cluster kubeconfig
output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.meu_cluster.kube_config[0].raw_config
  sensitive = true
}

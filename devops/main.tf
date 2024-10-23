terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.33.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Criação do Cluster Kubernetes
resource "digitalocean_kubernetes_cluster" "meu_cluster" {
  name    = "meu-cluster"
  region  = "nyc1"
  version = "1.31.1-do.3"

  node_pool {
    name       = "default-pool"
    size       = "s-1vcpu-2gb"
    node_count = 2
  }

  # Provisioner para rodar o comando doctl após a criação do cluster
  provisioner "local-exec" {
    command = "echo Iniciando kubeconfig... && doctl kubernetes cluster kubeconfig save meu-cluster && echo Kubeconfig salvo com sucesso!"
  }
}

# Provedor Kubernetes que usará o kubeconfig atualizado pelo doctl
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "do-nyc1-meu-cluster"
}

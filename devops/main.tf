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

  provisioner "local-exec" {
    command = <<-EOT
      echo "Iniciando kubeconfig..."
      doctl kubernetes cluster kubeconfig save meu-cluster
      echo "Kubeconfig salvo com sucesso!"
      echo "Aguardando cluster ficar pronto..."
      sleep 45
      kubectl wait --for=condition=Ready nodes --all --timeout=300s
      echo "Cluster está pronto!"
    EOT
  }
}

# Configuração do Provider Kubernetes
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.meu_cluster.endpoint
  token = digitalocean_kubernetes_cluster.meu_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.meu_cluster.kube_config[0].cluster_ca_certificate
  )
}
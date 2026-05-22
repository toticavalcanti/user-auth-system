terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.33.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Criação do Cluster Kubernetes
resource "digitalocean_kubernetes_cluster" "meu_cluster" {
  name    = var.cluster_name
  region  = "nyc1"
  version = var.cluster_version

  node_pool {
    name       = "default-pool"
    size       = "s-2vcpu-4gb"
    node_count = 2
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Iniciando kubeconfig..."
      doctl kubernetes cluster kubeconfig save ${var.cluster_name}
      echo "Kubeconfig salvo. Aguardando cluster ficar pronto..."
      sleep 45
      kubectl wait --for=condition=Ready nodes --all --timeout=300s
      echo "Cluster está pronto!"
    EOT
  }
}

provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.meu_cluster.endpoint
  token = digitalocean_kubernetes_cluster.meu_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.meu_cluster.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.meu_cluster.endpoint
    token = digitalocean_kubernetes_cluster.meu_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.meu_cluster.kube_config[0].cluster_ca_certificate
    )
  }
}
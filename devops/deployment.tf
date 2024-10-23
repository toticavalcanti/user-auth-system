# Backend Deployment
resource "kubernetes_deployment" "auth_api" {
  metadata {
    name = "auth-api"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "auth-api"
      }
    }
    template {
      metadata {
        labels = {
          app = "auth-api"
        }
      }
      spec {
        container {
          name  = "auth-api"
          image = "toticavalcanti/fiber-auth-api:v1.0"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_password
          }

          env {
            name  = "DB_DSN"
            value = "root:${var.mysql_root_password}@tcp(mysql-service:3306)/mysql"
          }

          port {
            container_port = 3000
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
  }
}

# Serviço do backend (ClusterIP)
resource "kubernetes_service" "auth_api" {
  metadata {
    name = "auth-api-service"
  }
  spec {
    selector = {
      app = "auth-api"
    }
    type = "ClusterIP"
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

# Frontend Deployment
resource "kubernetes_deployment" "auth_ui" {
  metadata {
    name = "auth-ui"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "auth-ui"
      }
    }
    template {
      metadata {
        labels = {
          app = "auth-ui"
        }
      }
      spec {
        container {
          name  = "auth-ui"
          image = "toticavalcanti/auth-ui:v1.0"

          env {
            name  = "REACT_APP_API_URL"
            value = "/api"
          }

          port {
            container_port = 80
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }
        }
      }
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
  }
}

# Serviço do Frontend (LoadBalancer)
resource "kubernetes_service" "auth_ui" {
  metadata {
    name = "auth-ui-service"
  }
  spec {
    selector = {
      app = "auth-ui"
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}

# Serviço do MySQL (ClusterIP, com IP fixo no cluster)
resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "mysql-service"
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = 3306
      target_port = 3306
    }
    cluster_ip = "None"
  }
}

# Persistent Volume
resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-pv"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = "manual"

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
  }
}

# Persistent Volume Claim
resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name = "mysql-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "manual"
  }
}

# MySQL Pod
resource "kubernetes_pod" "mysql_pod" {
  metadata {
    name = "mysql-pod"
    labels = {
      app = "mysql-pod"
    }
  }
  spec {
    container {
      name  = "mysql"
      image = "mysql:5.7"
      env {
        # Referenciando a senha do Secret como no YAML original
        name = "MYSQL_ROOT_PASSWORD"
        value_from {
          secret_key_ref {
            name = "mysql-secret"
            key  = "mysql-root-password"
          }
        }
      }
      resources {
        limits = {
          memory = "512Mi"
          cpu    = "500m"
        }
        requests = {
          memory = "256Mi"
          cpu    = "250m"
        }
      }
      volume_mount {
        mount_path = "/var/lib/mysql"
        name       = "mysql-storage"
      }
      port {
        container_port = 3306
      }
    }
    volume {
      name = "mysql-storage"
      persistent_volume_claim {
        claim_name = "mysql-pvc"
      }
    }
  }
}

# Secret for MySQL corrigido (sem base64encode, usando texto simples)
resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }
  data = {
    # Kubernetes codificará automaticamente o Secret
    mysql-root-password = var.mysql_root_password
  }
}

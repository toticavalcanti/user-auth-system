# Definição do deployment para o backend
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
            name  = "APP_URL"
            value = var.app_url
          }

          env {
            name  = "DB_DSN"
            value = var.db_dsn
          }

          port {
            container_port = 3000
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/health"  # Ajuste para o endpoint de saúde real da sua aplicação
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# Definição do deployment para o frontend
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
            value = var.app_url
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Expor o frontend usando LoadBalancer (para capturar o APP_URL)
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

# Expor o backend usando ClusterIP (interno ao cluster)
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
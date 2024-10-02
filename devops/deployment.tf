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
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "mysql-root-password"
              }
            }
          }

          env {
            name  = "APP_URL"
            value = var.app_url
          }

          env {
            name  = "DB_DSN"
            value = "root:$(MYSQL_ROOT_PASSWORD)@tcp(mysql-service:3306)/mysql"
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

          # readiness_probe {
          #   http_get {
          #     path = "/health"
          #     port = 3000
          #   }
          #   initial_delay_seconds = 10
          #   period_seconds        = 5
          # }
        }
      }
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
            value = "http://auth-api-service:3000"
          }

          port {
            container_port = 80
          }
        }
      }
    }
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
      port        = 80   # Usando a porta 80 para frontend
      target_port = 80
    }
  }
}

# Serviço do Backend (LoadBalancer)
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

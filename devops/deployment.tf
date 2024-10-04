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

          # Variável de ambiente do MySQL
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "mysql-root-password"
              }
            }
          }

          # Variável de ambiente APP_URL
          env {
            name  = "APP_URL"
            value = "${kubernetes_service.auth_ui.status[0].load_balancer[0].ingress[0].ip}"
          }

          # Variável de ambiente DB_DSN
          env {
            name  = "DB_DSN"
            value = "root:$(MYSQL_ROOT_PASSWORD)@tcp(mysql-service:3306)/mysql"
          }

          # Porta onde o backend escuta
          port {
            container_port = 3000
          }

          # Configuração de recursos
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

          # Readiness probe (opcional, descomentado se desejar usar)
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

          # Variável de ambiente para o frontend se comunicar com o backend
          env {
            name  = "REACT_APP_API_URL"
            value = "http://auth-api-service:3000"
          }

          # Porta onde o frontend escuta
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
      port        = 80   # Usando a porta 80 para o frontend
      target_port = 80
    }
  }
}

# Serviço do Backend (ClusterIP)
resource "kubernetes_service" "auth_api" {
  metadata {
    name = "auth-api-service"
  }
  spec {
    selector = {
      app = "auth-api"
    }
    type = "ClusterIP"   # Backend é exposto internamente com ClusterIP
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

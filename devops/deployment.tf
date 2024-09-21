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

          # Variáveis de ambiente para o backend
          env {
            name  = "MAILJET_API_KEY"
            value = var.mailjet_api_key
          }

          env {
            name  = "MAILJET_API_SECRET"
            value = var.mailjet_secret_key
          }

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

# Expor o backend usando ClusterIP
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

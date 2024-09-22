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
            value = var.app_url # URL da aplicação, será injetada dinamicamente
          }

          env {
            name  = "DB_DSN"
            value = var.db_dsn # String de conexão do banco de dados
          }

          port {
            container_port = 3000 # Porta usada pela aplicação
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

          # Variáveis de ambiente para o frontend (caso necessário)
          env {
            name  = "REACT_APP_API_URL"
            value = var.app_url # URL da API, será injetada dinamicamente
          }

          port {
            container_port = 80 # Porta do frontend
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
    type = "LoadBalancer" # Expõe o serviço para fora do cluster
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
    type = "ClusterIP" # Mantém o serviço apenas dentro do cluster
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

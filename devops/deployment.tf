# Adicionar este bloco no início do arquivo
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name = "nginx-config"
  }

  data = {
    "nginx.conf" = file("${path.module}/../frontend/react-auth/nginx.conf")
  }
}

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
        }
      }
    }
  }
}

# Serviço do backend alterado para ClusterIP
resource "kubernetes_service" "auth_api" {
  metadata {
    name = "auth-api-service"
  }
  spec {
    selector = {
      app = "auth-api"
    }
    type = "ClusterIP"  # Alterado para ClusterIP
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

          # Variável de ambiente para o frontend se comunicar com o backend
          env {
            name  = "REACT_APP_API_URL"
            value = "http://auth-api-service:3000"
          }

          # Porta onde o frontend escuta
          port {
            container_port = 80
          }

          # Volume mount para a configuração do Nginx
          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/conf.d"
          }
        }

        # Volume para a configuração do Nginx
        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
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
    cluster_ip = "None"  # IP fixo para o MySQL no cluster
  }
}
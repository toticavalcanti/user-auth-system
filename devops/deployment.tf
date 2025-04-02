# Data Source para o IP do Ingress Controller
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "default"
  }
  depends_on = [helm_release.ingress_nginx]
}
##################################
# SECRETS
##################################
resource "kubernetes_secret" "gmail_credentials" {
  metadata {
    name = "gmail-credentials"
  }
  data = {
    username = var.gmail_username
    password = var.gmail_password
  }
}

resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }
  data = {
    mysql-root-password = base64encode(var.mysql_root_password)
  }
}

##################################
# VOLUMES
##################################
resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-pv"
    labels = {
      type = "local"
      app  = "mysql"
    }
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "manual"
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path {
        path = "/mnt/data"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name = "mysql-pvc"
    labels = {
      app = "mysql"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "manual"
    volume_name        = kubernetes_persistent_volume.mysql_pv.metadata[0].name
  }
  depends_on = [
    kubernetes_persistent_volume.mysql_pv
  ]
}

##################################
# MYSQL: DEPLOYMENT E SERVICE
##################################
resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_password
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "mysql"
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

          port {
            container_port = 3306
            name           = "mysql"
          }

          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }

          readiness_probe {
            tcp_socket {
              port = 3306
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }

          liveness_probe {
            tcp_socket {
              port = 3306
            }
            initial_delay_seconds = 20
            period_seconds        = 10
          }
        }

        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubernetes_persistent_volume_claim.mysql_pvc]
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "mysql-service"
    labels = {
      app = "mysql"
    }
  }
  spec {
    selector = {
      app = "mysql"
    }
    type = "ClusterIP"
    port {
      port        = 3306
      target_port = 3306
      name        = "mysql"
    }
  }
}

##################################
# BACKEND: DEPLOYMENT E SERVICE
##################################
resource "kubernetes_deployment" "auth_api" {
  metadata {
    name = "auth-api"
    labels = {
      app = "auth-api"
    }
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
        init_container {
          name  = "wait-for-mysql"
          image = "busybox:1.28"
          command = [
            "sh", "-c",
            "until nc -z mysql-service 3306; do echo waiting for mysql; sleep 2; done;"
          ]
        }

        container {
          name  = "auth-api"
          image = "toticavalcanti/fiber-auth-api:v1.0"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_password
          }

          env {
            name  = "DB_DSN"
            value = "root:${var.mysql_root_password}@tcp(mysql-service:3306)/mysql?parseTime=true"
          }

          env {
            name = "GMAIL_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.gmail_credentials.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "GMAIL_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.gmail_credentials.metadata[0].name
                key  = "password"
              }
            }
          }

          # Se precisar, use para alguma lógica interna:
          env {
            name  = "APP_URL"
            value = "http://${data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip}"
          }

          port {
            container_port = 3000
            name           = "http"
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
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 20
            period_seconds        = 10
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_deployment.mysql,
    kubernetes_service.mysql_service
  ]
}

resource "kubernetes_service" "auth_api" {
  metadata {
    name = "auth-api-service"
    labels = {
      app = "auth-api"
    }
  }
  spec {
    selector = {
      app = "auth-api"
    }
    type = "ClusterIP"
    port {
      port        = 3000
      target_port = 3000
      name        = "http"
    }
  }
}

##################################
# FRONTEND: DEPLOYMENT E SERVICE
##################################
resource "kubernetes_deployment" "auth_ui" {
  metadata {
    name = "auth-ui"
    labels = {
      app = "auth-ui"
    }
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
          image = "toticavalcanti/auth-ui:v1.1"

          env {
            name  = "REACT_APP_API_URL"
            value = var.react_app_api_url # Ex.: "/api/"
          }

          command = ["/bin/sh", "-c"]
          # Usamos a sintaxe de HEREDOC no "args" para evitar problemas de escape
          args = [
            <<-EOT
              echo 'window._env_ = { REACT_APP_API_URL: \"${var.react_app_api_url}\" };' > /usr/share/nginx/html/config.js
              nginx -g 'daemon off;'
            EOT
          ]

          port {
            container_port = 80
            name           = "http"
          }

          readiness_probe {
            http_get {
              path = "/index.html"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 1
          }

          liveness_probe {
            http_get {
              path = "/index.html"
              port = 80
            }
            initial_delay_seconds = 15
            period_seconds        = 10
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 1
          }

          resources {
            limits = {
              cpu    = "200m"
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

  depends_on = [
    kubernetes_deployment.auth_api
  ]
}


resource "kubernetes_service" "auth_ui" {
  metadata {
    name = "auth-ui-service"
    labels = {
      app = "auth-ui"
    }
  }
  spec {
    selector = {
      app = "auth-ui"
    }
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 80
      name        = "http"
    }
  }
}

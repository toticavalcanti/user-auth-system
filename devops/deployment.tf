# Secret for MySQL
resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }
  data = {
    mysql-root-password = base64encode(var.mysql_root_password)
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

  depends_on = [kubernetes_persistent_volume.mysql_pv]
}

# MySQL Deployment
resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
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
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "mysql-root-password"
              }
            }
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
          }
          
          volume_mount {
            mount_path = "/var/lib/mysql"
            name       = "mysql-storage"
          }

          readiness_probe {
            exec {
              command = ["mysqladmin", "ping", "-h", "localhost"]
            }
            initial_delay_seconds = 30
            period_seconds       = 10
            timeout_seconds     = 5
          }

          liveness_probe {
            exec {
              command = ["mysqladmin", "ping", "-h", "localhost"]
            }
            initial_delay_seconds = 30
            period_seconds       = 10
            timeout_seconds     = 5
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
  }

  depends_on = [
    kubernetes_secret.mysql_secret,
    kubernetes_persistent_volume_claim.mysql_pvc
  ]
}

# MySQL Service
resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "mysql-service"
  }
  spec {
    selector = {
      app = "mysql"
    }
    type = "ClusterIP"
    port {
      port        = 3306
      target_port = 3306
    }
  }

  depends_on = [kubernetes_deployment.mysql]
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
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "mysql-root-password"
              }
            }
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

  depends_on = [
    kubernetes_deployment.mysql,
    kubernetes_service.mysql_service
  ]
}

# Backend Service
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

  depends_on = [kubernetes_deployment.auth_api]
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

  depends_on = [kubernetes_deployment.auth_api]
}

# Frontend Service
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

  depends_on = [kubernetes_deployment.auth_ui]
}
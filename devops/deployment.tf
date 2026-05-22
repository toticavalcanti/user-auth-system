# Data Source para o IP do Ingress Controller
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
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
        service_account_name            = kubernetes_service_account.mysql.metadata[0].name
        automount_service_account_token = false

        container {
          name  = "mysql"
          image = var.mysql_image

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_password
          }

          env {
            name  = "MYSQL_DATABASE"
            value = var.mysql_database
          }

          resources {
            limits = {
              memory = local.mysql_resources.limits.memory
              cpu    = local.mysql_resources.limits.cpu
            }
            requests = {
              memory = local.mysql_resources.requests.memory
              cpu    = local.mysql_resources.requests.cpu
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
    replicas = var.backend_replica_count
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
        service_account_name            = kubernetes_service_account.backend.metadata[0].name
        automount_service_account_token = false

        security_context {
          run_as_non_root = local.pod_security_context.run_as_non_root
          run_as_user     = local.pod_security_context.run_as_user
          run_as_group    = local.pod_security_context.run_as_group
          fs_group        = local.pod_security_context.fs_group
          seccomp_profile { type = "RuntimeDefault" }
        }

        init_container {
          name  = "wait-for-mysql"
          image = "busybox:1.28"
          command = [
            "sh", "-c",
            "until nc -z mysql-service 3306; do echo waiting for mysql; sleep 2; done;"
          ]
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 65534
            capabilities { drop = ["ALL"] }
          }
        }

        container {
          name  = "auth-api"
          image = var.backend_image

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_password
          }

          env {
            name  = "DB_DSN"
            value = "root:${var.mysql_root_password}@tcp(mysql-service:3306)/${var.mysql_database}?parseTime=true"
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

          env {
            name  = "APP_URL"
            value = "http://${data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip}"
          }

          security_context {
            allow_privilege_escalation = local.container_security_context.allow_privilege_escalation
            read_only_root_filesystem  = local.container_security_context.read_only_root_filesystem
            run_as_non_root            = local.container_security_context.run_as_non_root
            run_as_user                = local.container_security_context.run_as_user
            capabilities { drop = local.container_security_context.drop_capabilities }
          }

          port {
            container_port = 3000
            name           = "http"
          }

          resources {
            limits = {
              cpu    = local.backend_resources.limits.cpu
              memory = local.backend_resources.limits.memory
            }
            requests = {
              cpu    = local.backend_resources.requests.cpu
              memory = local.backend_resources.requests.memory
            }
          }

          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
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

        volume {
          name = "tmp-dir"
          empty_dir { medium = "Memory" }
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
        service_account_name            = kubernetes_service_account.frontend.metadata[0].name
        automount_service_account_token = false

        security_context {
          run_as_non_root = true
          run_as_user     = 101
          run_as_group    = 101
          fs_group        = 101
          seccomp_profile { type = "RuntimeDefault" }
        }

        container {
          name  = "auth-ui"
          image = var.frontend_image

          env {
            name  = "REACT_APP_API_URL"
            value = var.react_app_api_url
          }

          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
              echo 'window._env_ = { REACT_APP_API_URL: \"${var.react_app_api_url}\" };' > /usr/share/nginx/html/config.js
              nginx -g 'daemon off;'
            EOT
          ]

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 101
            capabilities { drop = ["ALL"] }
          }

          port {
            container_port = 80
            name           = "http"
          }

          resources {
            limits = {
              cpu    = local.frontend_resources.limits.cpu
              memory = local.frontend_resources.limits.memory
            }
            requests = {
              cpu    = local.frontend_resources.requests.cpu
              memory = local.frontend_resources.requests.memory
            }
          }

          volume_mount {
            name       = "nginx-cache"
            mount_path = "/var/cache/nginx"
          }
          volume_mount {
            name       = "nginx-run"
            mount_path = "/var/run"
          }
          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
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
        }

        volume {
          name = "nginx-cache"
          empty_dir { medium = "Memory" }
        }
        volume {
          name = "nginx-run"
          empty_dir { medium = "Memory" }
        }
        volume {
          name = "tmp-dir"
          empty_dir { medium = "Memory" }
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
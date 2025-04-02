resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name = "app-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "false"
      "nginx.ingress.kubernetes.io/use-regex"          = "true"
      "nginx.ingress.kubernetes.io/rewrite-target"     = "/$1"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "^/(api|login|register|logout|forgot|reset|user)(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "auth-api-service"
              port {
                number = 3000
              }
            }
          }
        }

        path {
          path      = "/(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "auth-ui-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx]
}

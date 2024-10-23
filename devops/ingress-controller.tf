# Ingress Controller - NGINX
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_service_account" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-serviceaccount"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "nginx_ingress_cluster_role" {
  metadata {
    name = "nginx-ingress-clusterrole"
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets", "services"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses/status", "ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "nginx_ingress_rolebinding" {
  metadata {
    name = "nginx-ingress-rolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.nginx_ingress_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.nginx_ingress.metadata[0].name
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
}

resource "kubernetes_deployment" "nginx_ingress_controller" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    labels = {
      app = "nginx-ingress-controller"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nginx-ingress-controller"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx-ingress-controller"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.nginx_ingress.metadata[0].name

        container {
          name  = "nginx-ingress-controller"
          image = "k8s.gcr.io/ingress-nginx/controller:v1.1.1"

          args = [
            "/nginx-ingress-controller",
            "--configmap=$(POD_NAMESPACE)/nginx-ingress-controller-config",
            "--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services",
            "--udp-services-configmap=$(POD_NAMESPACE)/udp-services"
          ]

          env {
            name  = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          port {
            container_port = 80
          }

          port {
            container_port = 443
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-service"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "nginx-ingress-controller"
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    port {
      name        = "https"
      port        = 443
      target_port = 443
    }
  }
}

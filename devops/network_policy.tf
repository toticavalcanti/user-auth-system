resource "kubernetes_network_policy" "default_deny_all" {
  metadata {
    name   = "default-deny-all"
    labels = local.common_labels
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "backend_ingress" {
  metadata {
    name   = "backend-ingress-policy"
    labels = local.common_labels
  }
  spec {
    pod_selector {
      match_labels = {
        app = "auth-api"
      }
    }
    policy_types = ["Ingress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "auth-ui"
          }
        }
      }
      ports {
        port     = "3000"
        protocol = "TCP"
      }
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }
      }
      ports {
        port     = "3000"
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_network_policy" "backend_egress" {
  metadata {
    name   = "backend-egress-policy"
    labels = local.common_labels
  }
  spec {
    pod_selector {
      match_labels = {
        app = "auth-api"
      }
    }
    policy_types = ["Egress"]

    egress {
      to {
        pod_selector {
          match_labels = {
            app = "mysql"
          }
        }
      }
      ports {
        port     = "3306"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "587"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "465"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_network_policy" "frontend_policy" {
  metadata {
    name   = "frontend-policy"
    labels = local.common_labels
  }
  spec {
    pod_selector {
      match_labels = {
        app = "auth-ui"
      }
    }
    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "ingress-nginx"
          }
        }
      }
      ports {
        port     = "80"
        protocol = "TCP"
      }
    }

    egress {
      to {
        pod_selector {
          match_labels = {
            app = "auth-api"
          }
        }
      }
      ports {
        port     = "3000"
        protocol = "TCP"
      }
    }

    egress {
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }
  }
}

resource "kubernetes_network_policy" "mysql_ingress" {
  metadata {
    name   = "mysql-ingress-policy"
    labels = local.common_labels
  }
  spec {
    pod_selector {
      match_labels = {
        app = "mysql"
      }
    }
    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "auth-api"
          }
        }
      }
      ports {
        port     = "3306"
        protocol = "TCP"
      }
    }
  }
}
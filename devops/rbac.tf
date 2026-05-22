resource "kubernetes_service_account" "backend" {
  metadata {
    name   = "backend-service-account"
    labels = local.common_labels
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "frontend" {
  metadata {
    name   = "frontend-service-account"
    labels = local.common_labels
  }
  automount_service_account_token = false
}

resource "kubernetes_service_account" "mysql" {
  metadata {
    name   = "mysql-service-account"
    labels = local.common_labels
  }
  automount_service_account_token = false
}

resource "kubernetes_role" "readonly_debugger" {
  metadata {
    name   = "readonly-debugger"
    labels = local.common_labels
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "backend_readonly" {
  metadata {
    name   = "backend-readonly-binding"
    labels = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.readonly_debugger.metadata[0].name
  }

  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.backend.metadata[0].name
  }
}
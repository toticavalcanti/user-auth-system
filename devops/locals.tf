locals {
  common_labels = {
    project    = "fiber-auth"
    managed-by = "terraform"
  }

  pod_security_context = {
    run_as_non_root = true
    run_as_user     = 65534
    run_as_group    = 65534
    fs_group        = 65534
  }

  container_security_context = {
    allow_privilege_escalation = false
    read_only_root_filesystem  = true
    run_as_non_root            = true
    run_as_user                = 65534
    drop_capabilities          = ["ALL"]
  }

  backend_resources = {
    requests = { cpu = "100m", memory = "128Mi" }
    limits   = { cpu = "500m", memory = "512Mi" }
  }

  frontend_resources = {
    requests = { cpu = "50m",  memory = "64Mi"  }
    limits   = { cpu = "200m", memory = "256Mi" }
  }

  mysql_resources = {
    requests = { cpu = "250m", memory = "512Mi" }
    limits   = { cpu = "500m", memory = "1Gi"   }
  }
}
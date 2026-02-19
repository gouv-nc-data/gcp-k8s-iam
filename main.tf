locals {
  sa_account_id  = substr("${var.name}-sa", 0, 30)
  sa_display     = var.display_name != null ? var.display_name : "Service Account for ${var.name}"
  secret_project = var.secret_project_id != "" ? var.secret_project_id : var.project_id
  gcp_sa_email   = var.create_service_account ? google_service_account.sa[0].email : var.service_account_email
  gcp_sa_name    = var.create_service_account ? google_service_account.sa[0].name : "projects/${var.project_id}/serviceAccounts/${var.service_account_email}"
}

# Service Account GCP
resource "google_service_account" "sa" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = local.sa_account_id
  display_name = local.sa_display
}

# Rôles IAM sur le projet
resource "google_project_iam_member" "roles" {
  for_each = var.create_service_account ? toset(var.gcp_roles) : toset([])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${local.gcp_sa_email}"
}

# Accès aux Secrets GCP
resource "google_secret_manager_secret_iam_member" "secret_access" {
  for_each = var.create_service_account ? toset(values(var.secrets)) : toset([])

  project   = local.secret_project
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.gcp_sa_email}"
}

# Permission pour puller des images (nécessaire pour Argo Workflow emissary)
resource "google_project_iam_member" "artifact_registry_reader" {
  count = var.image_gcp_project != null ? 1 : 0

  project = var.image_gcp_project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${local.gcp_sa_email}"
}

# Workload Identity binding (GCP SA ↔ K8s SA)
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = local.gcp_sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gke_project_id}.svc.id.goog[${var.namespace}/${kubernetes_service_account_v1.sa.metadata[0].name}]"
}

# Service Account Kubernetes
resource "kubernetes_service_account_v1" "sa" {
  metadata {
    name      = local.sa_account_id
    namespace = var.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = local.gcp_sa_email
    }
  }
}

# Création des rôles personnalisés
resource "kubernetes_role_v1" "custom" {
  for_each = { for r in var.k8s_custom_roles : r.name => r }

  metadata {
    name      = "${local.sa_account_id}-${each.key}"
    namespace = var.namespace
  }

  dynamic "rule" {
    for_each = each.value.rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

# Bindings (Externes + Custom)
resource "kubernetes_role_binding_v1" "k8s_roles" {
  for_each = merge(
    { for r in var.k8s_external_roles : "${r.kind}-${r.name}" => r },
    { for r in var.k8s_custom_roles : "role-${r.name}" => { kind = "Role", name = kubernetes_role_v1.custom[r.name].metadata[0].name } }
  )

  metadata {
    name      = "${local.sa_account_id}-${lower(each.value.kind)}-${each.value.name}"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = each.value.kind
    name      = each.value.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.sa.metadata[0].name
    namespace = var.namespace
  }
}

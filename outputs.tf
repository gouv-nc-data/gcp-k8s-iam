output "gcp_service_account_email" {
  value       = local.gcp_sa_email
  description = "Email du Service Account GCP"
}

output "k8s_service_account_name" {
  value       = kubernetes_service_account.sa.metadata[0].name
  description = "Nom du Service Account Kubernetes"
}

output "namespace" {
  value       = kubernetes_service_account.sa.metadata[0].namespace
  description = "Namespace du Service Account Kubernetes"
}

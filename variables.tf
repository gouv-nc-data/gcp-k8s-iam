variable "name" {
  description = "Nom du workload (utilisé pour nommer les SA)"
  type        = string
}

variable "namespace" {
  description = "Namespace Kubernetes"
  type        = string
}

variable "project_id" {
  description = "ID du projet GCP où créer le Service Account"
  type        = string
}

variable "gke_project_id" {
  description = "ID du projet GCP hébergeant le cluster GKE (pour Workload Identity)"
  type        = string
  default     = "prj-dinum-gke-f8f8"
}

variable "gcp_roles" {
  description = "Liste des rôles IAM à attribuer au Service Account sur le projet"
  type        = list(string)
  default     = []
}

variable "secret_project_id" {
  description = "ID du projet contenant les secrets GCP"
  type        = string
  default     = "prj-dinum-p-secret-mgnt-aaf4"
}

variable "secrets" {
  description = "Map de nom de variable → ID du secret GCP (sans le chemin projects/...)"
  type        = map(string)
  default     = {}
}

variable "display_name" {
  description = "Description du Service Account GCP (optionnel)"
  type        = string
  default     = null
}

variable "create_service_account" {
  description = "Créer un Service Account GCP dédié. Si false, utiliser service_account_email."
  type        = bool
  default     = true
}

variable "service_account_email" {
  description = "Email du SA GCP existant (requis si create_service_account = false)"
  type        = string
  default     = null
}

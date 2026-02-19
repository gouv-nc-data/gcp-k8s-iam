# Module Terraform - GKE IAM

Module pour créer un SA GCP lui affecter des rôles, créer un SA Kubernetes et l'associer à un SA GCP via Workload Identity.

## Usage

### Cas 1 : Création d'un Service Account dédié (Recommandé)

```hcl
module "iam" {
  source = "git::https://github.com/gouv-nc-data/gcp-k8s-iam.git?ref=v1"

  name       = "my-app"
  namespace  = "my-namespace"
  project_id = "my-gcp-project-id"

  # Rôles IAM à attribuer au SA GCP
  gcp_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ]

  # Accès aux secrets (facultatif)
  secrets = {
    DB_PASSWORD = "db-password-secret-id"
  }
}
```

### Cas 2 : Utilisation d'un Service Account existant

Dans ce cas, seul le Service Account Kubernetes et le binding Workload Identity sont créés. Les rôles et secrets doivent être gérés ailleurs.

```hcl
module "iam_existing" {
  source = "git::https://github.com/gouv-nc-data/gcp-k8s-iam.git?ref=v1"

  name                   = "my-app-existing"
  namespace              = "my-namespace"
  project_id             = "my-gcp-project-id"
  create_service_account = false
  service_account_email  = "existing-sa@my-gcp-project-id.iam.gserviceaccount.com"
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.20.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.artifact_registry_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret_iam_member.secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [kubernetes_role_binding_v1.k8s_roles](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding_v1) | resource |
| [kubernetes_role_v1.custom](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_v1) | resource |
| [kubernetes_service_account_v1.sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account) | Créer un Service Account GCP dédié. Si false, utiliser service\_account\_email. | `bool` | `true` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Description du Service Account GCP (optionnel) | `string` | `null` | no |
| <a name="input_gcp_roles"></a> [gcp\_roles](#input\_gcp\_roles) | Liste des rôles IAM à attribuer au Service Account sur le projet | `list(string)` | `[]` | no |
| <a name="input_gke_project_id"></a> [gke\_project\_id](#input\_gke\_project\_id) | ID du projet GCP hébergeant le cluster GKE (pour Workload Identity) | `string` | `"prj-dinum-gke-f8f8"` | no |
| <a name="input_image_gcp_project"></a> [image\_gcp\_project](#input\_image\_gcp\_project) | ID du projet GCP contenant les images Docker (pour donner accès au SA du workload) | `string` | `"prj-dinum-data-templates-66aa"` | no |
| <a name="input_k8s_custom_roles"></a> [k8s\_custom\_roles](#input\_k8s\_custom\_roles) | Rôles Kubernetes à créer et binder | <pre>list(object({<br/>    name = string<br/>    rules = list(object({<br/>      api_groups = list(string)<br/>      resources  = list(string)<br/>      verbs      = list(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_k8s_external_roles"></a> [k8s\_external\_roles](#input\_k8s\_external\_roles) | Rôles Kubernetes existants (Role ou ClusterRole) à binder | <pre>list(object({<br/>    kind = string<br/>    name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Nom du workload (utilisé pour nommer les SA) | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace Kubernetes | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID du projet GCP où créer le Service Account | `string` | n/a | yes |
| <a name="input_secret_project_id"></a> [secret\_project\_id](#input\_secret\_project\_id) | ID du projet contenant les secrets GCP | `string` | `"prj-dinum-p-secret-mgnt-aaf4"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map de nom de variable → ID du secret GCP (sans le chemin projects/...) | `map(string)` | `{}` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Email du SA GCP existant (requis si create\_service\_account = false) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_service_account_email"></a> [gcp\_service\_account\_email](#output\_gcp\_service\_account\_email) | Email du Service Account GCP |
| <a name="output_k8s_service_account_name"></a> [k8s\_service\_account\_name](#output\_k8s\_service\_account\_name) | Nom du Service Account Kubernetes |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace du Service Account Kubernetes |
<!-- END_TF_DOCS -->
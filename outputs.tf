# outputs.tf
# Values shown after 'terraform apply' - everything needed to use the platform

output "cluster_name" {
  description = "Name of the provisioned cluster"
  value       = module.cluster.cluster_name
}

output "kubeconfig_context" {
  description = "kubectl context for this cluster"
  value       = "kind-${module.cluster.cluster_name}"
}

output "workload_namespaces" {
  description = "Namespaces available for deployments"
  value       = module.namespaces.namespace_names
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = module.argocd.namespace
}

output "argocd_access" {
  description = "How to access the ArgoCD UI"
  value       = <<-EOT

    ArgoCD UI Access:
    ─────────────────
    1. Port-forward:
       kubectl port-forward svc/argocd-server -n argocd 8080:443 --context kind-${module.cluster.cluster_name}

    2. Open: https://localhost:8080

    3. Get admin password:
       kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" --context kind-${module.cluster.cluster_name} | base64 -d
  EOT
}
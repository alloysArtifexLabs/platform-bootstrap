
output "namespace" {
  description = "Namespace ArgoCD is installed in"
  value       = helm_release.argocd.namespace
}
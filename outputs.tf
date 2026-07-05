# Values shown after 'terraform apply'

output "cluster_name" {
  description = "Name of the provisioned cluster"
  value       = module.cluster.cluster_name
}

output "kubeconfig_path" {
  description = "Path to kubeconfig for kubectl access"
  value       = module.cluster.kubeconfig_path
}
# Values this module exposes to the root module.
# These feed the kubernetes/helm providers so they can talk to the cluster.

output "endpoint" {
  description = "Kubernetes API server endpoint"
  value       = kind_cluster.this.endpoint
}

output "client_certificate" {
  description = "Client certificate for cluster auth"
  value       = kind_cluster.this.client_certificate
}

output "client_key" {
  description = "Client key for cluster auth"
  value       = kind_cluster.this.client_key
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = kind_cluster.this.cluster_ca_certificate
}

output "kubeconfig_path" {
  description = "Path to the generated kubeconfig"
  value       = kind_cluster.this.kubeconfig_path
}

output "cluster_name" {
  description = "Name of the created cluster"
  value       = kind_cluster.this.name
}
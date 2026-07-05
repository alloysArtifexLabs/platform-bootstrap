# versions.tf
# Provider version pins for reproducible builds.
# Terraform will only use these exact provider versions.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # kind provider - creates the local Kubernetes cluster
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.5.1"
    }

    # helm provider - installs ArgoCD via its Helm chart
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }

    # kubernetes provider - creates namespaces and applies manifests
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }

    # kubectl provider - applies raw YAML (the app-of-apps root)
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}
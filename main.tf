# Root module - orchestrates all platform components

# ─────────────────────────────────────────────
# Cluster - provision the kind cluster first
# ─────────────────────────────────────────────
module "cluster" {
  source = "./modules/cluster"

  cluster_name = var.cluster_name
}

# ─────────────────────────────────────────────
# Provider configuration
# These providers authenticate to the cluster using
# the credentials output by the cluster module.
# ─────────────────────────────────────────────
provider "helm" {
  kubernetes {
    host                   = module.cluster.endpoint
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}

provider "kubernetes" {
  host                   = module.cluster.endpoint
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

provider "kubectl" {
  host                   = module.cluster.endpoint
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  load_config_file       = false
}
# ─────────────────────────────────────────────
# ArgoCD - installed via Helm into the cluster
# ─────────────────────────────────────────────
module "argocd" {
  source = "./modules/argocd"

  depends_on = [module.cluster]
}

# ─────────────────────────────────────────────
# Namespaces - workload namespaces (dev, prod)
# ─────────────────────────────────────────────
module "namespaces" {
  source = "./modules/namespaces"

  depends_on = [module.cluster]
}

# ─────────────────────────────────────────────
# Bootstrap - apply the app-of-apps root Application.
# This hands ongoing management over to ArgoCD/GitOps.
# ─────────────────────────────────────────────
module "bootstrap" {
  source = "./modules/bootstrap"

  depends_on = [module.argocd, module.namespaces]
}
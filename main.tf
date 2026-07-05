# Root module - orchestrates all platform components

# ─────────────────────────────────────────────
# Cluster - provision the kind cluster first
# ─────────────────────────────────────────────
module "cluster" {
  source = "./modules/cluster"

  cluster_name = var.cluster_name
}
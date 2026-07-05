# Installs ArgoCD via the official Helm chart.
# The helm_release resource creates the namespace and deploys
# all ArgoCD components (server, repo-server, application-controller).

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  # Wait for all ArgoCD pods to be ready before marking complete
  wait    = true
  timeout = 600

  # Reduce resource footprint for local kind cluster
  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "server.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "repoServer.resources.requests.memory"
    value = "128Mi"
  }
}
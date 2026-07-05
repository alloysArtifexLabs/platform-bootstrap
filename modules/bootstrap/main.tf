# Applies the app-of-apps root Application.
# kubectl_manifest applies raw YAML — used here because Application
# is a custom resource (CRD) that the kubernetes provider handles awkwardly.

resource "kubectl_manifest" "root_app" {
  yaml_body = file("${path.root}/bootstrap/root-app.yaml")
}
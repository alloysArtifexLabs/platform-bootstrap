# Platform Bootstrap

Infrastructure-as-Code that stands up a complete Kubernetes GitOps platform with a single `terraform apply` — cluster, ArgoCD, namespaces, and the app-of-apps pattern wired together. Tear it all down with `terraform destroy`. Zero manual steps.

Built to demonstrate treating platform provisioning itself as code — not just cloud resources, but the Kubernetes platform, its GitOps engine, and its self-management structure.

---

## What It Does

```
terraform apply
      │
      ├── [kind provider]        creates a 3-node Kubernetes cluster
      │
      ├── [helm provider]        installs ArgoCD via its official Helm chart
      │
      ├── [kubernetes provider]  creates dev + prod namespaces with labels
      │
      └── [kubectl provider]     applies the app-of-apps root Application
                                       │
                                       ▼
                              ArgoCD takes over management
                                       │
                              watches apps/ folder in Git
                                       │
                              auto-deploys every child Application
```

After bootstrap, the platform manages itself. Adding a new application is a one-file Git commit — no Terraform, no `kubectl`, no clicking.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                          terraform apply                          │
└───────────────────────────────┬──────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────────┐
│ module/cluster │      │ module/argocd │      │ module/namespaces │
│                │      │               │      │                   │
│ kind_cluster   │      │ helm_release  │      │ kubernetes_       │
│ 3 nodes        │──┬──▶│ argo-cd chart │      │ namespace         │
│                │  │   │               │      │ (dev, prod)       │
└───────────────┘  │   └───────────────┘      └───────────────────┘
                   │           │
                   │           ▼
                   │   ┌───────────────────┐
                   └──▶│ module/bootstrap  │
                       │                   │
                       │ kubectl_manifest  │
                       │ root-app.yaml     │
                       └─────────┬─────────┘
                                │
                                ▼
                       ┌─────────────────────────────┐
                       │      ArgoCD (root-app)       │
                       │   watches apps/ in Git        │
                       │                              │
                       │   ├── devsecops-demo         │
                       │   └── (add more here)        │
                       └─────────────────────────────┘
```

---

## Stack

| Layer | Tool | Purpose |
|---|---|---|
| IaC | Terraform | Provisions and manages the entire platform |
| Cluster | kind (via `tehcyx/kind`) | Local 3-node Kubernetes cluster |
| GitOps | ArgoCD (via Helm) | Declarative delivery, self-management |
| Manifests | kubectl provider | Applies the app-of-apps root Application |
| Pattern | App-of-apps | ArgoCD discovers and manages child apps from Git |

---

## Module Structure

```
platform-bootstrap/
├── main.tf                    # Root - provider config + module calls
├── variables.tf               # Root inputs
├── outputs.tf                 # Post-apply access info
├── versions.tf                # Provider version pins
├── modules/
│   ├── cluster/               # kind cluster
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf         # Exposes cluster credentials
│   │   └── versions.tf
│   ├── argocd/                # ArgoCD Helm release
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── namespaces/            # dev/prod with labels
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── bootstrap/             # Applies app-of-apps root
│       ├── main.tf
│       └── versions.tf
├── bootstrap/
│   └── root-app.yaml          # App-of-apps root Application
├── apps/
│   └── devsecops-demo.yaml    # Child Application (auto-discovered)
└── .gitignore                 # Excludes state, kubeconfig
```

---

## Design Decisions

**Modular structure.** Each module has a single responsibility — cluster, ArgoCD, namespaces, bootstrap. Modules expose only what downstream consumers need through outputs. This separation makes each piece testable and reusable, versus a single monolithic configuration file.

**Provider sources declared per module.** Child modules do not inherit provider sources from the root — each declares its own `required_providers`. This is a common Terraform gotcha; getting it right keeps modules self-contained and portable.

**State and kubeconfig excluded from Git.** Terraform state can contain secrets, and the generated kubeconfig contains cluster credentials. Both are in `.gitignore` and must never be committed. Committing them is one of the most common IaC security mistakes.

**Explicit dependency ordering.** `depends_on` ensures the cluster exists before ArgoCD installs, and ArgoCD exists before the root Application is applied. Terraform's dependency graph handles most ordering automatically, but the platform bootstrap sequence is made explicit for correctness.

**App-of-apps for self-management.** Terraform's job ends once the root Application is applied. From that point ArgoCD owns ongoing state, reconciling everything under `apps/` from Git. This is the clean handoff from provisioning (Terraform) to continuous delivery (ArgoCD).

---

## Usage

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Stand up the platform

```bash
git clone https://github.com/alloysArtifexLabs/platform-bootstrap.git
cd platform-bootstrap

terraform init
terraform apply
```

Type `yes` when prompted. The full platform comes up in ~5 minutes.

### Access ArgoCD

Terraform prints access instructions on completion. To view them again:

```bash
terraform output argocd_access
```

Port-forward and log in:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 --context kind-platform
```

Open `https://localhost:8080`. Get the admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" --context kind-platform | base64 -d
```

### Verify

```bash
kubectl get applications -n argocd --context kind-platform
```

You should see `root-app` and its discovered children.

### Add a new application to the platform

Drop an ArgoCD `Application` manifest into `apps/`, commit, and push:

```bash
# apps/my-new-app.yaml
git add apps/my-new-app.yaml
git commit -m "add my-new-app to platform"
git push
```

ArgoCD discovers and deploys it automatically. No Terraform, no manual `kubectl`.

### Tear it all down

```bash
terraform destroy
```

Type `yes`. The entire platform — cluster, ArgoCD, all workloads — is removed cleanly.

---

## Related Project

This platform deploys workloads from the companion DevSecOps pipeline repo:
[devsecops-k8s-pipeline](https://github.com/alloysArtifexLabs/devsecops-k8s-pipeline) — CodeQL SAST, Trivy scanning, OPA Gatekeeper admission control, and GitOps delivery.

---

## Author

**Alloys Obiero Omullo**
Senior Platform & DevOps Engineer
[LinkedIn](https://www.linkedin.com/in/alloys-omullo-2a9148204) · [GitHub](https://github.com/alloysArtifexLabs)
# Inputs this module accepts

variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "platform"
}

variable "node_image" {
  description = "kind node image (pins the Kubernetes version)"
  type        = string
  default     = "kindest/node:v1.30.0"
}
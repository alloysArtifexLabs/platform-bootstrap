
variable "namespaces" {
  description = "List of namespaces to create for workloads"
  type        = list(string)
  default     = ["dev", "prod"]
}
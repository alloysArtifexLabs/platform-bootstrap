# Creates workload namespaces with labels.
# The 'for_each' loop creates one namespace resource per entry
# in the namespaces list — cleaner than duplicating blocks.

resource "kubernetes_namespace" "workload" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value

    # Labels that identify these as managed platform namespaces.
    # These also make them ready for Gatekeeper policy targeting.
    labels = {
      "managed-by"  = "platform-bootstrap"
      "environment" = each.value
    }
  }
}
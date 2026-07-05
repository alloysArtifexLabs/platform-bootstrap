# Declares which providers this module requires.
# Child modules do NOT inherit provider sources from the root —
# each must declare its own required_providers block.

terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.5.1"
    }
  }
}
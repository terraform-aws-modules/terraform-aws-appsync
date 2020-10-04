terraform {
  required_version = ">= 0.12.6, < 0.14"

  required_providers {
    aws    = ">= 2.46, < 4.0"
    random = "~> 2"
  }
}

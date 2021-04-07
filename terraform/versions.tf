## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = "~> 0.12"
}

provider "local" {
  version = "~> 1.2"
}

provider "tls" {
  version = "~> 2.0"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}


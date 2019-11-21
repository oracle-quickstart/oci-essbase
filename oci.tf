/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

provider "oci" {
  version = "~> 3.36.0"
  region  = "${var.region}"
  auth    = "InstancePrincipal"
}

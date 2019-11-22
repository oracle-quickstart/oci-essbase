## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

provider "oci" {
  version = "~> 3.53.0"
  region  = var.region
  auth    = "InstancePrincipal"
}


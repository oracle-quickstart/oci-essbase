## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_objectstorage_namespace" "user" {
  count = "${var.enabled ? 1 : 0}"
  # TODO Enable  # compartment_id = "${var.compartment_id}"
}

resource "oci_objectstorage_bucket" "data" {
  count          = "${var.enabled ? 1 : 0}"
  compartment_id = "${var.compartment_id}"
  namespace      = "${join("", data.oci_objectstorage_namespace.user.*.namespace)}"
  name           = "${var.bucket_name}"
  access_type    = "NoPublicAccess"
}

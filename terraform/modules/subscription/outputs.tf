## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "image_id" {
  value = "${join("", oci_core_app_catalog_subscription.mp_image_subscription.*.listing_resource_id)}"
}

## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

output "image_id" {
  value = join("", oci_core_app_catalog_subscription.mp_image_subscription.*.listing_resource_id)
}


/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

output "image_id" {
  value = "${join("", oci_core_app_catalog_subscription.mp_image_subscription.*.listing_resource_id)}"
}

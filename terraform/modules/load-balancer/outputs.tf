## Copyright (c) 2019 - 2022, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  external_loadbalancer_ip = oci_load_balancer.loadbalancer.ip_address_details[0].ip_address
  redirect_url_prefix      = format("https://%s:443/essbase", local.external_loadbalancer_ip)
}

output "external_url" {
  value = format("https://%s/essbase", local.external_loadbalancer_ip)
}

output "redirect_url_prefix" {
  value = format("https://%s:443/essbase", local.external_loadbalancer_ip)
}


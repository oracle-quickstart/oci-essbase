## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

locals {
  external_loadbalancer_ip = element(local.public_ips[0], 0)
  external_url = local.enabled ? format(
    "https://%s/essbase",
    local.external_loadbalancer_ip,
  ) : ""

  redirect_url_prefix = local.enabled ? format(
    "https://%s:443/essbase",
    local.external_loadbalancer_ip,
  ) : ""
}

output "external_url" {
  value = local.external_url
}

output "redirect_url_prefix" {
  value = local.redirect_url_prefix
}


/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
locals {
  proto                    = "${var.enable_https ? "https" : "http"}"
  external_loadbalancer_ip = "${element(local.public_ips[0], 0)}"
  external_url             = "${local.enabled ? format("%s://%s/essbase", local.proto, local.external_loadbalancer_ip) : "" }"
}

output "external_url" {
  value = "${local.external_url}"
}

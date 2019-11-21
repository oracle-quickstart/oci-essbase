/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

locals {
  enabled    = "${var.enabled && var.subnet_count > 0 ? 1 : 0}"
  empty_list = "${list(list(""))}"
}

resource "oci_load_balancer" "loadbalancer" {
  count          = "${local.enabled ? 1 : 0}"
  shape          = "${var.shape}"
  compartment_id = "${var.compartment_id}"
  subnet_ids     = ["${flatten(var.subnet_ids)}"]
  display_name   = "${var.display_name_prefix}-loadbalancer"
}

locals {
  public_ips = "${coalescelist(oci_load_balancer.loadbalancer.*.ip_addresses, local.empty_list)}"
}

resource "tls_private_key" "demo_loadbalancer_cert" {
  count     = "${local.enabled && var.enable_https ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "demo_loadbalancer_cert" {
  count           = "${local.enabled && var.enable_https ? 1 : 0}"
  key_algorithm   = "${element(tls_private_key.demo_loadbalancer_cert.*.algorithm, count.index)}"
  private_key_pem = "${element(tls_private_key.demo_loadbalancer_cert.*.private_key_pem, count.index)}"

  ip_addresses = ["${flatten(oci_load_balancer.loadbalancer.*.ip_addresses)}"]

  subject {
    common_name         = "*.oraclevcn.com"
    organization        = "MyOrganization"
    organizational_unit = "FOR TESTING ONLY"
  }
}

resource "tls_locally_signed_cert" "demo_loadbalancer_cert" {
  count = "${local.enabled && var.enable_https ? 1 : 0}"

  cert_request_pem = "${element(tls_cert_request.demo_loadbalancer_cert.*.cert_request_pem, count.index)}"

  ca_key_algorithm   = "${var.demo_ca["algorithm"]}"
  ca_private_key_pem = "${var.demo_ca["private_key_pem"]}"
  ca_cert_pem        = "${var.demo_ca["cert_pem"]}"

  validity_period_hours = "8760"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

resource "oci_load_balancer_certificate" "demo-cert" {
  count            = "${local.enabled && var.enable_https ? 1 : 0}"
  load_balancer_id = "${oci_load_balancer.loadbalancer.id}"

  ca_certificate     = "${var.demo_ca["cert_pem"]}"
  certificate_name   = "demo"
  private_key        = "${element(tls_private_key.demo_loadbalancer_cert.*.private_key_pem, count.index)}"
  public_certificate = "${element(tls_locally_signed_cert.demo_loadbalancer_cert.*.cert_pem, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_backend_set" "essbase" {
  count            = "${var.enabled ? 1 : 0}"
  name             = "essbase"
  load_balancer_id = "${oci_load_balancer.loadbalancer.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/weblogic/ready"
  }

  session_persistence_configuration {
    cookie_name      = "JSESSIONID"
    disable_fallback = true
  }
}

resource "oci_load_balancer_backend" "essbase" {
  count = "${local.enabled ? var.node_count : 0}"

  load_balancer_id = "${oci_load_balancer.loadbalancer.id}"
  backendset_name  = "${oci_load_balancer_backend_set.essbase.name}"
  ip_address       = "${var.node_ip_addresses[count.index]}"
  port             = "80"
}

resource "oci_load_balancer_path_route_set" "essbase" {
  count = "${local.enabled ? 1 : 0}"

  #Required
  load_balancer_id = "${oci_load_balancer.loadbalancer.id}"
  name             = "essbase"

  path_routes {
    backend_set_name = "${oci_load_balancer_backend_set.essbase.name}"
    path             = "/essbase"

    path_match_type {
      match_type = "EXACT_MATCH"
    }
  }

  path_routes {
    backend_set_name = "${oci_load_balancer_backend_set.essbase.name}"
    path             = "/essbase/"

    path_match_type {
      match_type = "PREFIX_MATCH"
    }
  }
}

resource "oci_load_balancer_listener" "essbase" {
  count = "${local.enabled && !var.enable_https ? 1 : 0}"

  load_balancer_id         = "${oci_load_balancer.loadbalancer.id}"
  name                     = "http"
  default_backend_set_name = "${oci_load_balancer_backend_set.essbase.name}"
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "${var.idle_timeout}"
  }
}

resource "oci_load_balancer_listener" "essbase-https" {
  count = "${local.enabled && var.enable_https ? 1 : 0}"

  load_balancer_id         = "${oci_load_balancer.loadbalancer.id}"
  name                     = "https"
  default_backend_set_name = "${oci_load_balancer_backend_set.essbase.name}"
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = "${oci_load_balancer_certificate.demo-cert.certificate_name}"
    verify_peer_certificate = false
  }

  connection_configuration {
    idle_timeout_in_seconds = "${var.idle_timeout}"
  }
}

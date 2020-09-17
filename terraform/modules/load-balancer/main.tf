## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  enabled    = var.enabled && var.subnet_count > 0
  empty_list = [[""]]
}

resource "oci_load_balancer" "loadbalancer" {
  count          = local.enabled ? 1 : 0
  shape          = var.shape
  compartment_id = var.compartment_id
  subnet_ids   = var.subnet_ids
  display_name = "${var.display_name_prefix}-loadbalancer"
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
  is_private    = var.is_private
}

locals {
  ip_addresses = coalescelist(
    oci_load_balancer.loadbalancer.*.ip_addresses,
    local.empty_list,
  )
}

resource "tls_private_key" "demo_loadbalancer_cert" {
  count     = local.enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "demo_loadbalancer_cert" {

  count = local.enabled ? 1 : 0
  key_algorithm = element(
    tls_private_key.demo_loadbalancer_cert.*.algorithm,
    count.index,
  )
  private_key_pem = element(
    tls_private_key.demo_loadbalancer_cert.*.private_key_pem,
    count.index,
  )

  ip_addresses = flatten([for o in oci_load_balancer.loadbalancer : o.ip_address_details[*].ip_address])

  subject {
    common_name         = "*.oraclevcn.com"
    organization        = "MyOrganization"
    organizational_unit = "FOR TESTING ONLY"
  }

  validity_period_hours = "8760"

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

}

resource "oci_load_balancer_certificate" "demo-cert" {
  count            = local.enabled ? 1 : 0
  load_balancer_id = oci_load_balancer.loadbalancer[0].id

  certificate_name = "demo"
  private_key = element(
    tls_private_key.demo_loadbalancer_cert.*.private_key_pem,
    count.index,
  )
  public_certificate = element(
    tls_self_signed_cert.demo_loadbalancer_cert.*.cert_pem,
    count.index,
  )
  ca_certificate = element(
    tls_self_signed_cert.demo_loadbalancer_cert.*.cert_pem,
    count.index,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_backend_set" "essbase" {
  count            = var.enabled ? 1 : 0
  name             = "essbase"
  load_balancer_id = oci_load_balancer.loadbalancer[0].id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/weblogic/ready"

    interval_ms         = 5000
    timeout_in_millis   = 3000
  }

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.demo-cert[0].certificate_name
    verify_peer_certificate = false
  }

}

resource "oci_load_balancer_backend" "essbase" {

  count            = var.enabled ? 1 : 0
  load_balancer_id = oci_load_balancer.loadbalancer[0].id
  backendset_name  = oci_load_balancer_backend_set.essbase[0].name
  ip_address       = var.backend_node.ip_address
  port             = var.backend_node.port
}

resource "oci_load_balancer_path_route_set" "essbase" {
  count = local.enabled ? 1 : 0

  #Required
  load_balancer_id = oci_load_balancer.loadbalancer[0].id
  name             = "essbase"

  path_routes {
    backend_set_name = oci_load_balancer_backend_set.essbase[0].name
    path             = "/essbase"

    path_match_type {
      match_type = "EXACT_MATCH"
    }
  }

  path_routes {
    backend_set_name = oci_load_balancer_backend_set.essbase[0].name
    path             = "/essbase/"

    path_match_type {
      match_type = "PREFIX_MATCH"
    }
  }
}

resource "oci_load_balancer_rule_set" "essbase" {
  count = local.enabled ? 1 : 0

  load_balancer_id = oci_load_balancer.loadbalancer[0].id
  name             = "essbase"

  items {
    action = "REDIRECT"

    conditions {
      attribute_name  = "PATH"
      attribute_value = "/"
      operator        = "EXACT_MATCH"
    }

    redirect_uri {
      path     = "/essbase/jet/"
    }

    response_code = 307
  }

  items {
    action = "REDIRECT"

    conditions {
      attribute_name  = "PATH"
      attribute_value = "/essbase"
      operator        = "EXACT_MATCH"
    }

    redirect_uri {
      path     = "/essbase/jet/"
    }

    response_code = 307
  }

  items {
    action = "REDIRECT"

    conditions {
      attribute_name  = "PATH"
      attribute_value = "/essbase/"
      operator        = "EXACT_MATCH"
    }

    redirect_uri {
      path     = "/essbase/jet/"
    }

    response_code = 307
  }

}

resource "oci_load_balancer_listener" "essbase" {
  count = local.enabled ? 1 : 0

  load_balancer_id         = oci_load_balancer.loadbalancer[0].id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.essbase[0].name
  port                     = 443
  protocol                 = "HTTP"

  rule_set_names           = [ oci_load_balancer_rule_set.essbase[0].name ]

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.demo-cert[0].certificate_name
    verify_peer_certificate = false
  }

  connection_configuration {
    idle_timeout_in_seconds = var.idle_timeout
  }
}


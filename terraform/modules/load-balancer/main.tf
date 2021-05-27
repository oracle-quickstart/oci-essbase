## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_load_balancer" "loadbalancer" {
  shape          = var.shape
  compartment_id = var.compartment_id
  subnet_ids     = var.subnet_ids
  display_name   = "${var.display_name_prefix}-loadbalancer"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
  is_private     = var.is_private
}

resource "tls_private_key" "demo_loadbalancer_cert" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "demo_loadbalancer_cert" {

  key_algorithm = tls_private_key.demo_loadbalancer_cert.algorithm
  private_key_pem = tls_private_key.demo_loadbalancer_cert.private_key_pem
  ip_addresses = oci_load_balancer.loadbalancer.ip_address_details.*.ip_address

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
  load_balancer_id = oci_load_balancer.loadbalancer.id

  certificate_name = "demo"
  private_key = tls_private_key.demo_loadbalancer_cert.private_key_pem
  public_certificate = tls_self_signed_cert.demo_loadbalancer_cert.cert_pem
  ca_certificate = tls_self_signed_cert.demo_loadbalancer_cert.cert_pem

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_backend_set" "essbase" {
  name             = "essbase"
  load_balancer_id = oci_load_balancer.loadbalancer.id
  policy           = "ROUND_ROBIN"

  depends_on = [
    oci_load_balancer_certificate.demo-cert
  ]

  health_checker {
    protocol            = "HTTP"
    url_path            = "/weblogic/ready"

    interval_ms       = 5000
    timeout_in_millis = 3000
  }

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.demo-cert.certificate_name
    verify_peer_certificate = false
  }

  session_persistence_configuration {
    cookie_name = "JSESSIONID"
  }

}

resource "oci_load_balancer_backend" "essbase" {

  count            = length(var.backend_nodes)
  load_balancer_id = oci_load_balancer.loadbalancer.id
  backendset_name  = oci_load_balancer_backend_set.essbase.name
  ip_address       = var.backend_nodes[count.index].ip_address
  port             = var.backend_nodes[count.index].port
}

resource "oci_load_balancer_load_balancer_routing_policy" "essbase_routing_policy" {

  condition_language_version = "V1"
  load_balancer_id = oci_load_balancer.loadbalancer.id
  name = "essbase"
  rules {
     actions {
        name = "FORWARD_TO_BACKENDSET"
        backend_set_name = oci_load_balancer_backend_set.essbase.name
     }

     condition = "any(http.request.url.path eq '/essbase', http.request.url.path sw '/essbase/')"
     name = "essbase_url_match"
  }
}

resource "oci_load_balancer_rule_set" "essbase" {

  load_balancer_id = oci_load_balancer.loadbalancer.id
  name             = "essbase"

  items {
    action = "REDIRECT"

    conditions {
      attribute_name  = "PATH"
      attribute_value = "/"
      operator        = "EXACT_MATCH"
    }

    redirect_uri {
      path = "/essbase/jet/"
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
      path = "/essbase/jet/"
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
      path = "/essbase/jet/"
    }

    response_code = 307
  }

}

resource "oci_load_balancer_rule_set" "essbase-ssl-headers" {

  load_balancer_id = oci_load_balancer.loadbalancer.id
  name             = "ssl_headers"

  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "WL-Proxy-SSL"
    value  = "true"
  }

  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "is_ssl"
    value  = "ssl"
  }

}


resource "oci_load_balancer_listener" "essbase" {

  load_balancer_id         = oci_load_balancer.loadbalancer.id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.essbase.name
  port                     = 443
  protocol                 = "HTTP"

  rule_set_names = [
    oci_load_balancer_rule_set.essbase.name,
    oci_load_balancer_rule_set.essbase-ssl-headers.name
  ]

  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.demo-cert.certificate_name
    verify_peer_certificate = false
  }

  connection_configuration {
    idle_timeout_in_seconds = var.idle_timeout
  }
}


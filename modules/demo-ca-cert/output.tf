/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

output "cert_pem" {
  value = "${local.cert_pem}"
}

output "private_key_pem" {
  value     = "${local.private_key_pem}"
  sensitive = true
}

output "algorithm" {
  value = "RSA"
}

output "data" {
  value = {
    cert_pem        = "${local.cert_pem}"
    private_key_pem = "${local.private_key_pem}"
    algorithm       = "RSA"
  }

  sensitive = true
}

## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

/*
 * See https://www.akadia.com/services/ssh_test_certificate.html for instructions on generating the CA 
 */

locals {
  private_key_pem = file("${path.module}/files/demo-ca.key")
  cert_pem        = file("${path.module}/files/demo-ca.crt")
}


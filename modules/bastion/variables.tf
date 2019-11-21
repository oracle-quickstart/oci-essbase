## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "enabled" {
  default = false
}

variable "compartment_id" {}
variable "region" {}

variable "display_name_prefix" {}

variable "availability_domain" {}

variable "instance_shape" {
  default = "VM.Standard2.1"
}

variable "ssh_authorized_keys" {}

variable "subnet_id" {
  description = "The subnet id for the bastion node."
}

/*
* Using https://docs.cloud.oracle.com/iaas/images/image/1d157adc-42af-433c-a031-04f8e77d053a/
* Oracle-provided image = Oracle-Linux-7.6-2019.07.15-0
*
* Also see https://docs.us-phoenix-1.oraclecloud.com/images/ to pick another image in future.
*/
variable "bastion_instance_image_ocid" {
  type = "map"

  default = {
    ap-mumbai-1    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa74noijy4xbexah6elqtagiz2sr5rrmhp3iwph5c2esyauahgwk2q"
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaavntl5tdffjuhbuugj73cnwwd5z5obel4ivtxgeaicfofamjelh7q"
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaann6woj2cm3hguypjfx3ubv6lnwlk3x36kz775p273nvflgwy5fqq"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaat5xofe3k4wj55yikzpz33xcz6td5h7kb5x3vch555qt54ok3anva"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaakuepu6owftdo3qq2rftcoiwdhyj5jjxfdws6gxnv5gpdxpvtjnrq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaavrftjg3fa2uw5ndqin3tjme3jc4vpxnsysoxetlswsr6aqlfwurq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa5m7pxvywx2isnwon3o3kixkk6gq4tmdtfgvctj7xbl3wgo56uppa"
    us-langley-1   = "ocid1.image.oc2.us-langley-1.aaaaaaaa6mdubne7lvp75ttl32zyjurarnp6u3qazfj3nleinwd4xfryaomq"
    us-luke-1      = "ocid1.image.oc2.us-luke-1.aaaaaaaaunosincqm2bctskhewtkvqjy3awunwwm7mdcelitps2t33mdneva"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaajpign274mukkdwjqbzqanem4xqcmvu4mip3jbf5kzhrplqjwdkfq"
  }
}

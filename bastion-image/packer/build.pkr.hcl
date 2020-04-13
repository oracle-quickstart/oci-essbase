## Copyright (c) 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

build {

  sources = [
    "source.oracle-oci.bastion"
  ]

  provisioner "shell" {
    shell = file("${path.folder}/scripts/setup.sh")
    execute_command = "chmod +x {{ .Path }}; sudo /bin/bash -c '{{ .Vars }} {{ .Path }}'"
  }

  post-processor "manifest" {
    output = "/tmp/manifest.json"
  }

}

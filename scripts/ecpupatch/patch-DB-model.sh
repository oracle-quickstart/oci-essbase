## Copyright (c) 2019 - 2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/bin/bash -e
#
# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#Patches the DB terraform file to deploy in ECPU model

sed -i '' '/cpu_core_count           = "1"/ {
s/^/#/
a\
 compute_model            = "ECPU\
 compute_count            = "4.0"
}' ../../terraform/modules/database/main.tf
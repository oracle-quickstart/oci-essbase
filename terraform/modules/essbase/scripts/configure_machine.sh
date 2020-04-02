#!/bin/bash
# 
# Copyright (c) 2019, 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.
#

mkdir -p /var/log/essbase /var/run/essbase
chown opc:opc /var/log/essbase /var/run/essbase

/u01/vmtools/adjust-limits.sh

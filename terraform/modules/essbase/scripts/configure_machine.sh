#!/bin/bash
# 
# Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
#

mkdir -p /var/log/essbase /var/run/essbase
chown opc:opc /var/log/essbase /var/run/essbase

/u01/vmtools/adjust-limits.sh

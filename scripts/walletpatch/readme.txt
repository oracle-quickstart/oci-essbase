## Copyright (c) 2019 - 2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


Prologue:
--------------

DigiCert will stop trusting G1 root certificates (including TLS/SSL end-entity certificates) on April 15, 2026, per their announcement. This change may impact connectivity to Oracle Autonomous AI Database Serverless (ADB-S) for customers using mutual TLS (mTLS) authentication.

More details: https://blogs.oracle.com/autonomous-ai-database/autonomous-database-announcement-digicert


How to use patch:
--------------------------


1. Login to the customer machine

2. sudo dnf install -y patch
3. copy the wallet.patch file to /u01/vmtools ( using preferred FTP tool or scp )
4. sudo su oracle
5. cd /u01/vmtools
6. patch -p0 < wallet.patch

verify the changes by running rotate-schema-credentials.sh script.
 
To reverse the patch you can use

1. cd /u01/vmtools 
2. patch -r -p0 < wallet.patch








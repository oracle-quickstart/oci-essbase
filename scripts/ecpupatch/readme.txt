## Copyright (c) 2019 - 2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

Patch file patch-DB-model.sh
----------------------------------------

Prologue:

The DB model was changed from ocpu to ecpu model from Essbase releases from 21.7.3.0.1 as per Autonomous DB changes affecting OCI.
Details: https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-compute-models.html
This renders previous Essbase releases of Essbase on github unusable.
The patch script will execute and change the DB stack file to update it to ecpu model.

How to run:

Run the patch script on the scripts folder as kept in the github as 
./patch-DB-model.sh
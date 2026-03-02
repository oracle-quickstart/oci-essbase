## Copyright (c) 2019 - 2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


Prologue:
--------------

DigiCert will stop trusting G1 root certificates (including TLS/SSL end-entity certificates) on April 15, 2026, per their announcement. This change may impact connectivity to Oracle Autonomous AI Database Serverless (ADB-S) for customers using mutual TLS (mTLS) authentication.

More details: https://blogs.oracle.com/autonomous-ai-database/autonomous-database-announcement-digicert

How to use patch:
--------------------------

Method 1: If patch file can be copied to customer environment:
	
	1. Login to the customer machine
	2. sudo bash
	3. dnf install patch
	4. copy the wallet.patch file to /u01/vmtools ( using preferred FTP tool or scp )
	5. cd /u01/vmtools
	6. patch -p0 < wallet.patch
	7.verify the changes by running rotate-schema-credentials.sh script.
 
	To reverse the patch you can use
	1. cd /u01/vmtools 
	2. patch -r -p0 < wallet.patch


Method 2: If patch file cannot be copied to customer environment, copy and paste the below multiline script as root:

	1. Login to the customer machine
	2. sudo bash
	3. dnf install patch
	4. copy and paste the below multiline script and run
patch -p0 <<EOF
> --- init/configure-essbase-domain.py 2026-02-27 07:27:39.330078921 +0000
> +++ init/configure-essbase-domain.py.mod2026-02-27 07:28:09.771875840 +0000
> @@ -212,7 +212,7 @@
>     databaseId=databaseConfig.get_database_id()
>     databaseInfo = adb_utils.waitForAvailable(databaseId)
>  
> -   (databaseWalletArchiveLocation, databaseWalletPassword) = adb_utils.downloadWalletArchive(databaseId, dir = '/u01/tmp')
> +   (databaseWalletArchiveLocation, databaseWalletPassword) = adb_utils.downloadOCIWalletArchive(databaseId, dir = '/u01/tmp')
>     try:
>        databaseWalletLocation = tempfile.mkdtemp(prefix='wallet_', dir="/u01/tmp")
>  
> --- sysman/rotate-schema-credentials.py 2026-02-27 07:28:45.112801009 +0000
> +++ sysman/rotate-schema-credentials.py.mod2026-02-27 07:29:12.264511794 +0000
> @@ -116,7 +116,7 @@
>     if not os.path.exists(databaseWalletsRoot):
>        os.makedirs(databaseWalletsRoot)
>     
> -   (databaseWalletArchiveLocation, databaseWalletPassword) = adb_utils.downloadWalletArchive(databaseId, dir = '/u01/tmp')
> +   (databaseWalletArchiveLocation, databaseWalletPassword) = adb_utils.downloadOCIWalletArchive(databaseId, dir = '/u01/tmp')
>     try:
>        databaseWalletLocation = "%s/wallet_%s" % (databaseWalletsRoot, datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S"))
>  
> --- scripts/adb_utils.py 2026-02-27 07:29:38.144189281 +0000
> +++ scripts/adb_utils.py.mod2026-02-27 07:30:39.960807546 +0000
> @@ -12,6 +12,7 @@
>  import string
>  import essbase
>  import logging
> +import subprocess
>  
>  def randomWalletPassword():
>  
> @@ -104,6 +105,60 @@
>        except IOError:
>           sys.stderr.write('Failed to clean up temp dir {}'.format(databaseWalletLocation))
>  
> +def downloadOCIWalletArchive(databaseId, dir='/tmp'):
> +    logging.info("Downloading wallet for database %s via OCI CLI", databaseId)
> +
> +    walletPassword = "Welcome1"
> +
> +    fd, walletLocation = tempfile.mkstemp(suffix='.zip', prefix='wallet', dir=dir)
> +    os.close(fd)
> +
> +    # OCI CLI command:
> +    # oci db autonomous-database generate-wallet --autonomous-database-id <ocid> --password <pw> --file <path> --auth instance_principal
> +    cmd = [
> +        "oci", "db", "autonomous-database", "generate-wallet",
> +        "--autonomous-database-id", databaseId,
> +        "--password", walletPassword,
> +        "--file", walletLocation,
> +        "--auth", "instance_principal"
> +    ]
> +
> +    # Avoid logging the password; if you log cmd, redact it.
> +    try:
> +        proc = subprocess.run(
> +            cmd,
> +            stdout=subprocess.PIPE,
> +            stderr=subprocess.PIPE,
> +            universal_newlines=True,
> +            check=False
> +        )
> +
> +        if proc.returncode != 0:
> +            # map common permission error
> +            if "NotAuthorizedOrNotFound" in (proc.stderr or "") or "Forbidden" in (proc.stderr or ""):
> +                raise essbase.EssbaseError(
> +                    'ESSPROV-10002',
> +                    "Permission denied trying to download wallet for target database %s" % databaseId
> +                )
> +
> +            raise RuntimeError(
> +                "OCI CLI generate-wallet failed (rc=%s). stderr=%s" % (proc.returncode, proc.stderr.strip())
> +            )
> +
> +        # Basic sanity check: non-empty and looks like a zip
> +        if not os.path.exists(walletLocation) or os.path.getsize(walletLocation) < 4:
> +            raise RuntimeError("Wallet download produced an empty file: %s" % walletLocation)
> +
> +        with open(walletLocation, "rb") as f:
> +            if f.read(2) != b"PK":
> +                raise RuntimeError("Wallet download did not look like a ZIP file: %s" % walletLocation)
> +
> +        return (walletLocation, walletPassword)
> +
> +    except Exception:
> +        deleteWalletFile(walletLocation)
> +        raise
> +
>  
>  def downloadWalletArchive(databaseId, dir = '/tmp'):
>  
> EOF





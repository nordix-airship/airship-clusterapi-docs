#!/usr/bin/env bash
# This is enabling IMA measurement temporarily
# Need to set up grub/boottime parameters for permanent measurements
# If it doesn't work, grub config for safe startup:
# GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX ima=on integrity_audit=1 lsm=integrity,ima"

# policy is auditing: change "audit" to "measure"

# check requirements (tpm2-tools)
set -e
command -v tpm2_startup &>/dev/null

# don't fail
set -x
set +e

# Enable IMA measurement
echo "1" | sudo tee /sys/kernel/security/ima/policy_update
mkdir -p /etc/ima
sudo tee /etc/ima/ima-policy << 'EOF'
# Default IMA policy
# Don't measure files opened with read-only permissions
dont_measure obj_type=file mask=MAY_READ
# Measure all executed files
audit func=BPRM_CHECK mask=MAY_EXEC
# Measure files mmap()ed for execute
audit func=FILE_MMAP mask=MAY_EXEC
# Measure files opened for write or append
audit func=FILE_CHECK mask=MAY_WRITE uid=0
EOF

# load the ima policy
sudo cat /etc/ima/ima-policy | sudo tee /sys/kernel/security/ima/policy

# Configure TPM PRC - this needs
# setup tpm2-tools to access the tpmserver in docker
export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"
tpm2_startup -c

# PCR 10 will store IMA measurements
tpm2_pcrextend 10:sha256=0000000000000000000000000000000000000000000000000000000000000000

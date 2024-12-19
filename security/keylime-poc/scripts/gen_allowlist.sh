#!/usr/bin/env bash
# Script to generate file hashes for allowlist
# redirect to target file "allowlist.txt"

set -eu

cat <<EOF
# Allowlist format - use hashes of known good files
exclude: !policy
  - boot_aggregate
  - ima-buf
  - ima-sig
  - ima-ng

EOF

echo "# Generated allowlist"
echo "hashes:"

# List of critical directories to measure
DIRS_TO_MEASURE=(
    "/bin"
    "/sbin"
    "/usr/bin"
    "/usr/sbin"
    "/lib/systemd"
    "/usr/lib/systemd"
)

for dir in "${DIRS_TO_MEASURE[@]}"; do
    if [[ -d "${dir}" ]]; then
        find "${dir}" -type f -exec sha256sum {} \; | while read -r hash file; do
            echo "  ${file}: ${hash}"
        done
    fi
done
echo

# Read current IMA measurements
echo "ima:"
sudo cat /sys/kernel/security/ima/ascii_runtime_measurements | while read -r _ hash template file; do
    if [[ "${template}" == "ima-ng" ]]; then
        echo "  ${file}:"
        echo "    hash: ${hash}"
        echo "    validation_mask: 0xd"
    fi
done

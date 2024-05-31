#!/bin/bash
usage() {
    cat <<EOF
Usage: $0
Copy all scripts and configurations to STOCKPILE_DIR, no args needed.
EOF
}
CONFIG_FILE="./config.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    source "${CONFIG_FILE}"
else
    echo "Configuration file ${CONFIG_FILE} not found!"
    exit 1
fi
cp -v *.sh *.conf $STOCKPILE_DIR

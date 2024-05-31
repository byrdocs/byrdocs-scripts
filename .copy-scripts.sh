#!/bin/bash
usage() {
    cat <<EOF
Usage: $0
Copy all scripts and configurations to STOCKPILE_DIR, no args needed.
EOF
}
CONFIG_FILE="./.config.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    source "${CONFIG_FILE}"
else
    echo "Configuration file ${CONFIG_FILE} not found!"
    exit 1
fi
scripts=(".check-commands.sh" "edit-book-cover.sh" "extract-cover.sh" "organize.sh" "remove-duplicate.sh")
cp -v .*.conf "${STOCKPILE_DIR}"
for script in "${scripts[@]}"; do
    cp -v "${script}" "${STOCKPILE_DIR}"
done

#!/bin/bash
usage() {
    cat <<EOF
Usage: $0 <pattern> ...

Remove all files with the name matching '<pattern>' in 'byrdocs.org/'
EOF
}
if [[ "$#" -lt 1 ]]; then
    usage
    exit 1
fi
CONFIG_FILE="./.config.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    source "${CONFIG_FILE}"
else
    echo "Configuration file ${CONFIG_FILE} not found!"
    exit 2
fi
for pat in "$@"; do
    find "${BYRDOCS_DIR}" -name "$pat"
    echo -n "Do you wish to remove these files? (y/n) "
    read -n 1 -s yn
    echo
    case "${yn}" in
        y|Y) find "${BYRDOCS_DIR}" -name "$pat" -exec rm -v {} \; ;;
        n|N) echo "Skipped $pat" ;;
        *) echo "Invalid input. Skipped $pat" ;;
    esac
	echo
done

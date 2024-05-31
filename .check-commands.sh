#!/bin/bash
usage() {
    cat <<EOF
Usage: $0 [COMMAND]...

Checks if the specified commands are available on the system.

Examples:
  $0 bash
  $0 gcc make

If any command is not found, an error message will be displayed and the script will exit with a non-zero status.
Otherwise, the script will exit with 0 without displaying any message
EOF
    exit 0
}
check_commands() {
    for cmd in "$@"; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed."
            exit 1
        fi
    done
}
if [[ "$#" -eq 0 ]]; then
    usage
fi
check_commands "$@"

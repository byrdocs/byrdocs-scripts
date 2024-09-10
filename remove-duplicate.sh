#!/bin/zsh-5.9
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <source-dir> <reference-dir>
Remove files from source-dir that have the same md5sum as reference-dir.

Options:
  -r, --recursive       operate recursively in source-dir
  -v, --verbose         explain what is being done
  -h, --help            show this help message
EOF
}
process_single() {
    local file=$1
    local refdir=$2
    local md5=$(md5sum "${file}" | cut -d ' ' -f 1)
    local file_path=$(realpath "${file}")
    find "${refdir}" -type f -name "${md5}.*" | while read ref_file; do
        local ref_file_path=$(realpath "${ref_file}")
        if [[ "${file_path}" != "${ref_file_path}" ]]; then
            if [[ "${verboseQ}" -eq 1 ]]; then
                rm -v "${file}"
                exit 0
            else
                rm "${file}"
                exit 0
            fi
        fi
    done
}
if [[ "$#" -eq  0 ]]; then
    usage
    exit 1
fi
CONFIG_FILE="./.config.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    source "${CONFIG_FILE}"
else
    echo "Configuration file ${CONFIG_FILE} not found!"
    exit 1
fi
recursiveQ=0
verboseQ=0
OPTIONS=$(getopt -o rvh --long recursive,verbose,help -n 'parse-options' -- "$@")
eval set -- "${OPTIONS}"
while true; do
    case $1 in
        -r|--recursive)
            recursiveQ=1
            shift
            ;;
        -v|--verbose)
            verboseQ=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option: $1"
            ;;
    esac
done
if [[ "$#" -ne 2 ]]; then
    echo "Error: Exactly two paths must be provided."
    exit 2
fi
source=$1
reference=$2
if [[ ! -d "${source}" ]]; then
    echo "Error: ${source} is not a directory."
    exit 3
fi
if [[ ! -d "${reference}" ]]; then
    echo "Error: ${reference} is not a directory."
    exit 3
fi
export verboseQ
if [[ "${recursiveQ}" -eq 1 ]]; then
    find "${source}" -type f | while read -r file; do
        if [[ -f "${file}" ]]; then
            process_single "${file}" "${reference}"
        fi
    done
else
    for file in "${source}"/*; do
        if [[ -f "${file}" ]]; then
            process_single "${file}" "${reference}"
        fi
    done
fi

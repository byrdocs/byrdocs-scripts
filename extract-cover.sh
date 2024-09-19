#!/bin/zsh-5.9
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <path-to-file-or-dir> <path-to-dest>
Extract cover picture from one pdf file, or from all pdf files in a directory.

Options:
  -r, --recursive   process a directory recursively
  -j, --jpg         output with jpg
  -w, --webp        output with webp
  -J, --nojpg       output without jpg
  -W, --nowebp      output without webp
  -v, --verbose     explain what is being done
  -h, --help        show this help message

Notice: this command is only available to pdf files, or directories containing pdf files
If both --jpg and --nojpg are provided, the one appeared last will be settled.
EOF
}
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi
GLOBAL_CONFIG_FILE="./.config.conf"
if [[ -f "${GLOBAL_CONFIG_FILE}" ]]; then
    source "${GLOBAL_CONFIG_FILE}"
else
    echo "Configuration file ${GLOBAL_CONFIG_FILE} not found!"
    exit 1
fi
jpgQ=$GENERATE_JPG
webpQ=$GENERATE_WEBP
recursiveQ=0;
verboseQ=0;
if [[ -f "/tmp/organize-properties.conf" ]]; then
    source "/tmp/organize-properties.conf"
fi
OPTIONS=$(getopt -o rjpwJPWvh --long recursive,jpg,webp,nojpg,nowebp,verbose,help -n 'parse-options' -- "$@")
eval set -- "${OPTIONS}"
while true; do
    case $1 in
        -r|--recursive)
            recursiveQ=1
            shift
            ;;
        -j|--jpg)
            jpgQ=1
            shift
            ;;
        -w|--webp)
            webpQ=1
            shift
            ;;
        -J|--nojpg)
            jpgQ=0
            shift
            ;;
        -W|--nowebp)
            webpQ=0
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
if [[ "$?" -ne 0 ]]; then
    exit 2
fi
echo "verboseQ=${verboseQ}" > /tmp/extract-cover-properties.conf
echo "jpgQ=${jpgQ}" >> /tmp/extract-cover-properties.conf
echo "webpQ=${webpQ}" >> /tmp/extract-cover-properties.conf
input_path=$1
output_dir=$2
mkdir -p "${output_dir}"
if [[ "${recursiveQ}" -eq 1 ]]; then
    if [[ -d "${input_path}" ]]; then
		find "${input_path}" -type f -name '*.pdf' -exec zsh -c './.extract-single-cover.sh "$0" "$1"' {} "${output_dir}" \;
    else
        echo "Error: ${input_path} is a directory"
        exit 3
    fi
else
    if [[ "${input_path}" == *.pdf ]]; then
        ./.extract-single-cover.sh "${input_path}" "${output_dir}"
    else
        echo "Error: The input file is not a PDF."
        exit 4
    fi
fi

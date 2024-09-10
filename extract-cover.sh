#!/bin/zsh-5.9
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <path-to-file-or-dir> <path-to-dest>
Extract cover picture from one pdf file, or from all pdf files in a directory.

Options:
  -r, --recursive   process a directory recursively
  -j, --jpg         output with jpg
  -p, --png         output with png
  -w, --webp        output with webp
  -J, --nojpg       output without jpg
  -P, --nopng       output without png
  -W, --nowebp      output without webp
  -v, --verbose     explain what is being done
  -h, --help        show this help message

Notice: this command is only available to pdf files, or directories containing pdf files
If both --jpg and --nojpg are provided, the one appeared last will be settled.
EOF
}
process_single() {
    local pdf=$1
    local output_dir=$2
	cropbox_l=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $4}')))
	cropbox_b=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $5}')))
	cropbox_r=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $6}')))
	cropbox_t=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $7}')))
	crop_width=$((cropbox_r - cropbox_l))
	crop_height=$((cropbox_t - cropbox_b))
    base_name=$(basename "${pdf}" .pdf)
    base_path="${output_dir}/${base_name}"
    pdftoppm -singlefile -jpeg -r 144 "${pdf}" "/tmp/ori"
	magick "/tmp/ori.jpg" -crop ${crop_width}x${crop_height}+${cropbox_l}+${cropbox_b} "/tmp/tmp.jpg"
    if [[ "${jpgQ}" -eq 1 ]]; then
        cp "/tmp/tmp.jpg" "${base_path}.jpg"
        if [[ "${verboseQ}" -eq 1 ]]; then
            echo "Extracted '${base_path}.jpg'"
        fi
    fi
    if [[ "${pngQ}" -eq 1 ]]; then
        magick "/tmp/tmp.jpg" "${base_path}.png"
        if [[ "${verboseQ}" -eq 1 ]]; then
            echo "Extracted '${base_path}.png'"
        fi
    fi
    if [[ "${webpQ}" -eq 1 ]]; then
        cwebp -mt -resize 465 645 -quiet "/tmp/tmp.jpg" -o "${base_path}.webp"
        if [[ "${verboseQ}" -eq 1 ]]; then
            echo "Extracted '${base_path}.webp'"
        fi
    fi
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
SCRIPT_CONFIG_FILE="./.config-extract-cover.conf"
if [[ -f "${SCRIPT_CONFIG_FILE}" ]]; then
    source "${SCRIPT_CONFIG_FILE}"
else
    echo "Configuration file ${SCRIPT_CONFIG_FILE} not found!"
    exit 1
fi
recursiveQ=0;
jpgQ=$GENERATE_JPG
pngQ=$GENERATE_PNG
webpQ=$GENERATE_WEBP
verboseQ=0;
OPTIONS=$(getopt -o rjpwJPWvh --long recursive,jpg,png,webp,nojpg,nopng,nowebp,verbose,help -n 'parse-options' -- "$@")
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
        -p|--png)
            pngQ=1
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
        -P|--nopng)
            pngQ=0
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
./.check-commands.sh pdftoppm magick cwebp
if [[ "$?" -ne 0 ]]; then
    exit 2
fi
input_path=$1
output_dir=$2
mkdir -p "${output_dir}"
export -f process_single
export output_dir
export jpgQ
export pngQ
export webpQ
export verboseQ
if [[ "${recursiveQ}" -eq 1 ]]; then
    if [[ -d "${input_path}" ]]; then
        find "${input_path}" -type f -name '*.pdf' -exec bash -c 'process_single "$0" "${output_dir}"' {} \;
    else
        echo "Error: ${input_path} is a directory"
        exit 3
    fi
else
    if [[ "${input_path}" == *.pdf ]]; then
        process_single "${input_path}" "${output_dir}"
    else
        echo "Error: The input file is not a PDF."
        exit 4
    fi
fi

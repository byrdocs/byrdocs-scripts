#!/bin/bash
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <path-to-file-or-dir> <path-to-dest>
Extract cover picture from one pdf file, or from all pdf files in a directory

Options:
  -r, --recursive   process a directory recursively
  -p, --png         output with png
  -J, --nojpg       output without jpg
  -W, --nowebp      output without webp
  -v, --verbose     explain what is being done
  -h, --help        show this help message

Notice: this command is only available to pdf files, or directories containing pdf files
EOF
}
process_single() {
    local pdf=$1
    local output_dir=$2
    base_name=$(basename "${pdf}" .pdf)
    base_path="${output_dir}/${base_name}"
    pdftoppm -f 1 -l 1 -singlefile -jpeg -jpegopt quality=100 "${pdf}" "${base_path}"
    if [[ "${pngQ}" -eq 1 ]]; then
        magick "${base_path}.jpg" "${base_path}.png"
    fi
    magick "${base_path}.jpg" -resize 1024x1024 -define jpeg:extent=500kb "${base_path}.jpg"
    if [[ "${webpQ}" -eq 1 ]]; then
        cwebp -mt -quiet -size 10240 "${base_path}.jpg" -o "${base_path}.webp"
    fi
    if [[ "${jpgQ}" -eq 0 ]]; then
        rm "${base_path}.jpg"
    fi
    if [[ "${verboseQ}" -eq 1 ]]; then
        echo "Extracted covers from ${pdf}"
    fi
}
if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi
recursiveQ=0;
pngQ=0;
jpgQ=1;
webpQ=1;
verboseQ=0;
OPTIONS=$(getopt -o rpJWvh --long recursive,png,nojpg,nowebp,verbose,help -n 'parse-options' -- "$@")
eval set -- "${OPTIONS}"
while true; do
    case $1 in
        -r|--recursive)
            recursiveQ=1
            shift
            ;;
        -p|--png)
            pngQ=1
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
./check-commands.sh pdftoppm magick cwebp
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
        find "${input_path}" -type f -name *.pdf -exec bash -c 'process_single "$0" "${output_dir}"' {} \;
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
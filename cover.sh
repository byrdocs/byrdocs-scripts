#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path-to-pdf-file> <path-to-output-directory>"
    exit 1
fi

for cmd in pdftoppm convert cwebp; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it to continue."
        exit 1
    fi
done

pdf=$1
output_dir=$2
mkdir -p "${output_dir}"
base_name=$(basename "${pdf}" .pdf)
base_path="${output_dir}/${base_name}"
pdftoppm -f 1 -l 1 -singlefile -jpeg -jpegopt quality=100 "${pdf}" "${base_path}"
convert "${base_path}.jpg" -resize 1024x1024 -define jpeg:extent=500kb "${base_path}.jpg"
    cwebp -mt -size 10240 "${base_path}.jpg" -o "${base_path}.webp"
echo "Converted ${pdf} to ${base_path}.{png,jpg}"

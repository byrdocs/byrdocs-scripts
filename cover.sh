#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path-to-directory> <path-to-output-directory>"
    exit 1
fi

for cmd in pdftoppm convert cwebp; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it to continue."
        exit 1
    fi
done

input_dir=$1
output_dir=$2
mkdir -p "$output_dir"

find "$input_dir" -type f -name "*.pdf" | while read pdf_file; do
    base_name=$(basename "$pdf_file" .pdf)

    path="$output_dir/${base_name}"

    pdftoppm -f 1 -l 1 -singlefile -jpeg -jpegopt quality=100 "$pdf_file" "$path"
    convert "$path.jpg" -resize 1024x1024 -define jpeg:extent=500kb "$path.jpg"
		cwebp -mt -size 10240 "$path.jpg" -o "$path.webp"
    echo "Converted $pdf_file to $path.{png,jpg}"
done


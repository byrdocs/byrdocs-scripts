#!/bin/bash
if [ "$#" -ne 2 ]; then
    cat <<EOF
Usage: $0 [OPTION]... <pdf-file> <cover-img>

EOF
    exit 1
fi
ori=$1
img=$2
dir=$(dirname "${ori}")
convert "${img}" 'img.pdf'
#`imagemagic` is required for `convert`
pdftk "img.pdf" "${ori}" cat output 'tmp.pdf'
#`pdftk` is required
md5=$(md5sum "tmp.pdf" | cut -d ' ' -f 1)
echo $md5
destination="${dir}/${md5}.pdf"
mv "tmp.pdf" "${destination}"
echo "${ori} -> ${destination}"
rm "img.pdf"

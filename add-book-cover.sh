#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pdf-file> <cover-img>"
    exit 1
fi
ori=$1
img=$2
dir=$(dirname "${ori}")
convert $img 'img.pdf'
#`imagemagic` is required for `convert`
pdftk 'img.pdf' $ori cat output 'tmp.pdf'
md5=$(md5sum 'tmp.pdf' | cut -d ' ' -f 1)
echo $md5
destination="${dir}/${md5}.pdf"
mv 'tmp.pdf' $destination
echo "${ori} -> $destination"
rm 'img.pdf'
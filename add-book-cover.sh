#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pdf-file> <png-cover>"
    exit 1
fi
ori=$1
png=$2
dir=$(dirname "${ori}")
convert $png 'png.pdf'
pdftk 'png.pdf' $ori cat output 'tmp.pdf'
md5=$(md5sum 'tmp.pdf' | cut -d ' ' -f 1)
echo $md5
destination="${dir}/${md5}.pdf"
mv 'tmp.pdf' $destination
echo "${ori} -> $destination"
rm 'png.pdf'
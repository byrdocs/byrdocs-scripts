#!/bin/bash
#Notice: Be cautious with this command! After this operation, both the png and original pdf will be deleted.
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pdf-file> <png-cover>"
    exit 1
fi
ori=$1
png=$2
dir=$(dirname "${ori}")
convert $png 'png.pdf'
pdftk 'png.pdf' $ori cat output 'tmp.pdf'
mv 'tmp.pdf' $ori
md5=$(md5sum ${ori} | cut -d ' ' -f 1)
destination="${dir}/${md5}.pdf"
mv -v $ori "${destination}"
rm $png 'png.pdf'

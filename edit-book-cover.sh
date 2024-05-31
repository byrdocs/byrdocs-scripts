#!/bin/bash
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <pdf-file> <cover-file>
Add or replace the cover of a pdf file.
the cover-file should be pdf or any image type

Options:
  -r, --replace     replace the original cover (add cover by default)
  -h, --help        show this help message
EOF
}
if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
fi
replaceQ=0
OPTIONS=$(getopt -o rh --long replace,help -n 'parse-options' -- "$@")
eval set -- "${OPTIONS}"
while true; do
    case $1 in
        -r|--replace)
            replaceQ=1
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
    echo "Error: missing pdf file or cover file, or redundant files are provided."
    exit 2
fi
ori=$1
img=$2
./.check-commands.sh magick pdftk
if [[ "$?" -ne 0 ]]; then
    exit 2
fi
if [[ "${img}" == *.pdf ]]; then
    pdftk "${img}" cat 1 output 'img.pdf'
else
    magick "${img}" 'img.pdf'
fi
if [[ "${replaceQ}" -eq 1 ]]; then
    pdftk A='img.pdf' B="${ori}" cat A B2-end output 'tmp.pdf'
else
    pdftk A='img.pdf' B="${ori}" cat A B1-end output 'tmp.pdf'
fi
md5=$(md5sum "tmp.pdf" | cut -d ' ' -f 1)
mv 'tmp.pdf' "${md5}.pdf"
echo "${ori} -> ${md5}.pdf"
rm 'img.pdf'

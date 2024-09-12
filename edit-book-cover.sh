#!/bin/zsh-5.9
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <pdf-file> <cover-file>
Add or replace the cover of a pdf file.
The cover-file should be pdf or any image type.

Options:
  -r, --replace     replace the original cover (add cover by default)
  -u, --url         downlad cover-file from url instead of using local file
  -h, --help        show this help message
EOF
}
if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
fi
replaceQ=0
urlQ=0
OPTIONS=$(getopt -o ruh --long replace,url,help -n 'parse-options' -- "$@")
eval set -- "${OPTIONS}"
while true; do
    case $1 in
        -r|--replace)
            replaceQ=1
            shift
            ;;
		-u|--url)
			urlQ=1
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
ori=$1
if [[ "$#" -ne 2 ]]; then
    echo "Error: missing pdf file or cover file, or redundant files are provided."
    exit 2
fi
if [[ "$urlQ" -eq 1 ]]; then
	img=$(wget -c --content-disposition --spider --show-progress -P /tmp $2 2>&1 | grep -oP '(?<=Saving to: ‘)[^’]+')
	if [[ "$?" -ne 0 ]]; then
		echo "Can't download the file from url. Maybe the file is existing in /tmp"
		exit 3
	fi
else
	img=$2
fi
./.check-commands.sh wget magick pdftk
if [[ "$?" -ne 0 ]]; then
    exit 2
fi
if [[ "${img}" == *.pdf ]]; then
    pdftk "${img}" cat 1 output "/tmp/edit-book-cover-img.pdf"
else
    magick "${img}" "/tmp/edit-book-cover-img.pdf"
fi
if [[ "${replaceQ}" -eq 1 ]]; then
    pdftk A="/tmp/edit-book-cover-img.pdf" B="${ori}" cat A B2-end output "/tmp/edit-book-cover-tmp.pdf"
else
    pdftk A="/tmp/edit-book-cover-img.pdf" B="${ori}" cat A B1-end output "/tmp/edit-book-cover-tmp.pdf"
fi
md5=$(md5sum "/tmp/edit-book-cover-tmp.pdf" | cut -d ' ' -f 1)
mv "/tmp/edit-book-cover-tmp.pdf" "${md5}.pdf"
echo "${ori} -> ${md5}.pdf"

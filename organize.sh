#!/bin/bash
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <file>

Options:
  -c, --cover       generate covers
  -R, --noreview    don't review the file
  -h, --help        show this help message

Input category: <category>
Category options:
  b     books
  t     tests
  d     docs

Notice: You should store the file in the directory 'stockpile' and run this command here.
EOF
}
if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
fi
cover=0
review=1
OPTIONS=$(getopt -o chR --long cover,help,noreview -n 'parse-options' -- "$@")
eval set -- "${OPTIONS}"
while true; do
    case $1 in
        -c|--cover)
            cover=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -R|--noreview)
            review=0
            shift
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
if [[ "$#" -ne 1 ]]; then
    echo "Error: Exactly one file must be provided."
    exit 1
fi
file="$1"
if [[ ! -f "${file}" ]]; then
    echo "Error: File does not exist."
    exit 2
fi
extension="${file##*.}"
md5=$(md5sum "${file}" | cut -d ' ' -f 1)
echo $md5
if [[ cover -eq 1 ]]; then
    ./check-commands.sh pdftoppm convert cwebp
    if [[ "$?" -ne 0 ]]; then
        exit 3
    fi
fi
if [[ review -eq 1 ]]; then
    case "${extension}" in
        "pdf")
            ./check-commands.sh okular
            if [[ "$?" -ne  0 ]]; then
                exit 3
            fi
            okular "${file}"
            ;;
        "zip")
            ./check-commands.sh ark
            if [[ "$?" -ne 0 ]]; then
                exit 3
            fi
            ark "${file}"
            ;;
    esac
fi
read -p "Input category: " category
case $category in
    b)
        category="books"
        ;;
    t)
        category="tests"
        ;;
    d)
        category="docs"
        ;;
    *)
        echo "Invalid category!"
        echo "b for books, t for tests, d for docs"
        exit 4
        ;;
esac
destination="../${category}/${md5}.${extension}"
mv -v "${file}" "${destination}"
if [[ cover -eq 1 ]]; then
    ./extract-cover.sh -v "../${category}/${md5}.${extension}" "../covers"
fi

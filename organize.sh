#!/bin/bash
usage() {
    echo "Usage: $0 [OPTION]... <file>"
    echo
    echo "Options"
    echo "--cover, -c        generate covers by the way ()"
    echo "--help, -h         show this help"
    echo "--noreview, -R     don't review the file"
    echo
    echo "Notice: You should store the file in the directory 'stockpile' and run this command here"
    echo
    exit 1
}
if [[ "$#" -eq 0 ]]; then
    usage
fi
cover=0
review=1
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -c|--cover)
            cover=1
            shift
            ;;
        -h|--help)
            usage
            ;;
        -R|--noreview)
            review=0
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            file="$1"
            shift
            ;;
    esac
done
extension="${file##*.}"
md5=$(md5sum "${file}" | cut -d ' ' -f 1)
if [[ ! -f "${file}" ]]; then
    echo "Error: File does not exist."
    exit 2
fi
if [[ review -eq 1 ]]; then
    for cmd in okular ark; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed. Please install it to continue."
            exit 3
        fi
    done
fi
if [[ cover -eq 1 ]]; then
    for cmd in pdftoppm convert cwebp; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed. Please install it to continue."
            exit 3
        fi
done
fi
echo $md5
if [[ review -eq 1 ]]; then
    if [[ "${extension}" = "pdf" ]]; then
        okular "${file}" #`okular` is required for pdf viewer
    elif [[ "${extension}" = "zip" ]]; then
        ark "${file}" #`ark` is required for zip processor
    fi
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
        echo -e "Invalid category!\nb for books, t for tests, d for docs"
        exit 4
        ;;
esac
destination="../${category}/${md5}.${extension}"
mv -v "${file}" "${destination}"
if [[ cover -eq 1 ]]; then
    ./cover.sh "../${category}/${md5}.${extension}" "../covers"
fi

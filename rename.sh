#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi
FILE="$1"
if [ ! -f "${FILE}" ]; then
    echo "Error: File does not exist."
    exit 2
fi
EXTENSION="${FILE##*.}"
MD5SUM=$(md5sum "${FILE}" | cut -d ' ' -f 1)
echo $MD5SUM
if [ "${EXTENSION}" = "pdf" ]; then
    evince "${FILE}"
elif [ "${EXTENSION}" = "zip" ]; then
    file-roller "${FILE}"
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
        exit 3
        ;;
esac
DEST="../${category}/${MD5SUM}.${EXTENSION}"
mv -v "${FILE}" "${DEST}"

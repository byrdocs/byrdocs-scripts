#!/bin/bash
#Notice: You should store the file in the directory 'byrdocs.org/stockpile' and run this command here
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi
file=$1
if [ ! -f "${file}" ]; then
    echo "Error: File does not exist."
    exit 2
fi
extension="${file##*.}"
md5=$(md5sum "${file}" | cut -d ' ' -f 1)
echo $md5
if [ "${extension}" = "pdf" ]; then
    evince "${file}"
elif [ "${extension}" = "zip" ]; then
    file-roller "${file}"
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
destination="../${category}/${md5}.${extension}"
mv -v "${file}" "${destination}"

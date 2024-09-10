#!/bin/zsh-5.9
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <front-pdf> <back-pdf>"
    exit 1
fi
front_pdf=$1
back_pdf=$2
./.check-commands.sh pdftk
if [[ "$?" -ne 0 ]]; then
	exit 1
fi
num_pages=$(pdftk "${front_pdf}" dump_data | grep NumberOfPages | cut -d ' ' -f 2)
if [ -z "${num_pages}" ]; then
    echo "Error: Unable to determine the number of pages in the PDFs."
    exit 2
fi
pdftk_cmd="pdftk A=${front_pdf} B=${back_pdf} cat"
for ((i=1; i<=num_pages; i++)); do
    pdftk_cmd+=" A${i}"
    pdftk_cmd+=" B$((num_pages - i + 1))"
done
pdftk_cmd+=" output merged.pdf"
eval "${pdftk_cmd}"
echo "Merged ${front_pdf} and ${back_pdf} as merged.pdf"

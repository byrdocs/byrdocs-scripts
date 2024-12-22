#!/bin/zsh-5.9
usage() {
	cat <<EOF
Usage: $0 <path-to-single-pdf> <output-dir>
Extract cover (jpg and webp) from single pdf file.
EOF
}
pdf=$1
output_dir=$2
md5=$(md5sum "${pdf}" | cut -d ' ' -f 1)
./.check-commands.sh pdfinfo gs pdftoppm cwebp
cropbox_l=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep -a "CropBox" | awk '{print $4}')))
cropbox_b=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep -a "CropBox" | awk '{print $5}')))
cropbox_r=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep -a "CropBox" | awk '{print $6}')))
cropbox_t=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep -a "CropBox" | awk '{print $7}')))
crop_width=$((cropbox_r - cropbox_l))
crop_height=$((cropbox_t - cropbox_b))
base_name=$(basename "${pdf}" .pdf)
base_path="${output_dir}/${base_name}"
gs -dQUIET -o "/tmp/extract-single-tmp.pdf" -sDEVICE=pdfwrite -dLastPage=1 -c "${cropbox_l} ${cropbox_b} ${crop_width} ${crop_height} rectclip" -f "${pdf}"
pdftoppm -singlefile -jpeg -r 144 "/tmp/extract-single-tmp.pdf" "/tmp/extract-single-tmp"
cp "/tmp/extract-single-tmp.jpg" "${base_path}.jpg"
cwebp -mt -resize 465 645 -quiet "/tmp/extract-single-tmp.jpg" -o "${base_path}.webp"

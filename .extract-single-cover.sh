#!/bin/zsh-5.9
usage() {
	cat <<EOF
Usage: $0 <path-to-single-pdf> <output-dir>
Extract cover from single pdf file.

Notice: This command shouldn't be used independently. You should use extract-cover.sh.
EOF
}
if [[ -f "/tmp/extract-cover-properties.conf" ]]; then
	source "/tmp/extract-cover-properties.conf"
else
	echo "Configuration file /tmp/extract-cover-properties.conf not found!"
	echo "Please use this command through extract-cover.sh."
	exit 1
fi
pdf=$1
output_dir=$2
md5=$(md5sum "${pdf}" | cut -d ' ' -f 1)
if [[ -f ".magick-except.conf" ]]; then
	source ".magick-except.conf"
else
	MAGICK_EXCEPTION=()
fi
magick_exception=0
for item in "${MAGICK_EXCEPTION[@]}"; do
	if [[ "${item}" == "${md5}" ]]; then
		magick_exception=1
		break
	fi
done
./.check-commands.sh pdfinfo pdftoppm magick cwebp
cropbox_l=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $4}')))
cropbox_b=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $5}')))
cropbox_r=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $6}')))
cropbox_t=$((2*$(pdfinfo -box -f 1 -l 1 "${pdf}" | grep "CropBox" | awk '{print $7}')))
crop_width=$((cropbox_r - cropbox_l))
crop_height=$((cropbox_t - cropbox_b))
base_name=$(basename "${pdf}" .pdf)
base_path="${output_dir}/${base_name}"
gs -dQUIET -o "/tmp/extract-single-tmp.pdf" -sDEVICE=pdfwrite -dLastPage=1 -c "${cropbox_l} ${cropbox_b} ${crop_width} ${crop_height} rectclip" -f "${pdf}"
pdftoppm -singlefile -jpeg -r 144 "/tmp/extract-single-tmp.pdf" "/tmp/extract-single-tmp"
if [[ "${jpgQ}" -eq 1 ]]; then
	cp "/tmp/extract-single-tmp.jpg" "${base_path}.jpg"
	if [[ "${verboseQ}" -eq 1 ]]; then
		echo "Extracted '${base_path}.jpg'"
	fi
fi
if [[ "${webpQ}" -eq 1 ]]; then
	cwebp -mt -resize 465 645 -quiet "/tmp/extract-single-tmp.jpg" -o "${base_path}.webp"
	if [[ "${verboseQ}" -eq 1 ]]; then
		echo "Extracted '${base_path}.webp'"
	fi
fi

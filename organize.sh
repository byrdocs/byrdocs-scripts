#!/bin/zsh-5.9
usage() {
    cat <<EOF
Usage: $0 [OPTION]... <file>

Options:
  -j, --jpg         generate cover jpg
  -w, --webp        generate cover webp
  -J, --nojpg       do not generate cover jpg
  -W, --nowebp      do not generate cover webp
  -R, --noreview    do not review the file
  -v, --verbose     print more details
  -h, --help        show this help message

Default options are stored in ./config_organize.conf.
If both --jpg and --nojpg are provided, the one appeared last will be settled.

Input category: <category>
Category options:
  b     books
  t     tests
  d     docs
  R     (type this to remove that file)

Notice: You should store the file in the directory 'stockpile' and run this command here.
EOF
}
if [[ "$#" -eq 0 ]]; then
    usage
    exit 1
fi
CONFIG_FILE="./.config.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    source "${CONFIG_FILE}"
else
    echo "Configuration file ${CONFIG_FILE} not found!"
    exit 1
fi
jpgQ=$GENERATE_JPG
webpQ=$GENERATE_WEBP
verboseQ=0
reviewQ=1
OPTIONS=$(getopt -o jpwJPWvhR --long jpg,webp,noJPG,noWEBP,verbose,help,noreview -n 'parse-options' -- "$@")
eval set -- "${OPTIONS}"
while true; do
    case $1 in
        -j|--jpg)
            jpgQ=1
            shift
            ;;
        -w|--webp)
            webpQ=1
            shift
            ;;
        -J|--nojpg)
            jpgQ=0
            shift
            ;;
        -W|--nowebp)
            webpQ=0
            shift
            ;;
        -v|--verbose)
            verboseQ=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -R|--noreview)
            reviewQ=0
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
    exit 2
fi
file="$1"
if [[ ! -f "${file}" ]]; then
    echo "Error: File does not exist."
    exit 3
fi
extension="${file##*.}"
md5=$(md5sum "${file}" | cut -d ' ' -f 1)
dirs_to_find=("${BOOKS_DIR}" "${TESTS_DIR}" "${DOCS_DIR}")
if [[ -n $(find "${dirs_to_find[@]}" -type f -name "${md5}.*") ]]; then
    echo "There are already some files named ${md5}. Please check them:"
    find "${dirs_to_find[@]}" -type f -name "${md5}.*"
    exit 5
fi
echo $md5
./.check-before-organize.sh
if [[ "$?" -ne 0 ]]; then
	exit 10
fi
if [[ "$jpgQ" -eq 1 ]] || [[ "$webpQ" -eq 1 ]]; then
    ./.check-commands.sh pdftoppm cwebp
    if [[ "$?" -ne 0 ]]; then
        exit 5
    fi
fi
if [[ "$reviewQ" -eq 1 ]]; then
    case "${extension}" in
        "pdf")
            ./.check-commands.sh $PDF_VIEWER
            if [[ "$?" -ne  0 ]]; then
                exit 5
            fi
            $PDF_VIEWER "${file}"
            ;;
        "zip")
            ./.check-commands.sh $ZIP_VIEWER
            if [[ "$?" -ne 0 ]]; then
                exit 5
            fi
            $ZIP_VIEWER "${file}"
            ;;
    esac
fi
echo -n "Input category: "
read category
case $category in
    b)
        category="${BOOKS_DIR}"
        ;;
    t)
        category="${TESTS_DIR}"
        ;;
    d)
        category="${DOCS_DIR}"
        ;;
	R)
		rm -v "${file}"
		exit 0
		;;
    *)
        echo "Invalid category!"
        echo "b for books, t for tests, d for docs"
        exit 6
        ;;
esac
destination="${category}/${md5}.${extension}"
mv -v "${file}" "${destination}"
if [[ "${extension}" == "pdf" ]]; then
	echo "verboseQ=${verboseQ}" > /tmp/organize-properties.conf
	echo "jpgQ=${jpgQ}" >> /tmp/organize-properties.conf
	echo "webpQ=${webpQ}" >> /tmp/organize-properties.conf
	./extract-cover.sh "${destination}" "${COVERS_DIR}"
fi

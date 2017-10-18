#!/bin/bash

# pdf4search.sh (ver.20171018)
# Usage: pdf4search.sh FILENAME.pdf

# References:
# [1] https://qiita.com/dinosauria123/items/0feb719eb935fea62dd9
# [2] https://github.com/dinosauria123/gcv2hocr
# [3] https://github.com/tmbdev/hocr-tools

# user's variables
GCP_APIKEY=*****Your-Google-Cloud-Platform-API-Key*****
COMMAND_GCVOCR=/path/to/gcvocr.sh # [2]
COMMAND_GCV2HOCR=/usr/local/bin/gcv2hocr # [2]
# variables
FILE_PDF="$1"
TMP_FILENAME=${FILE_PDF##*/}
FILE_PDF_FILENAME=${TMP_FILENAME%.*}
TMP_DIR=/tmp/pdf4search_${FILE_PDF_FILENAME}
TMP_DPI=300

# pdf -> png
mkdir -p "${TMP_DIR}"
pdftoppm -r ${TMP_DPI} -png "${FILE_PDF}" "${TMP_DIR}/page"

# png -> Google Cloud Vision -> hocr+jpg
for FILE_PNG in $( find ${TMP_DIR} -type f -name '*.png' | sort ); do
	TMP_FILENAME=${FILE_PNG##*/}
	FILE_PNG_FILENAME=${TMP_FILENAME%.*}
	FILE_HOCR=${TMP_DIR}/${FILE_PNG_FILENAME}.hocr
	FILE_JSON=${FILE_PNG}.json
	echo "gcvocr.sh: ${FILE_PNG} > ${FILE_JSON}"
	${COMMAND_GCVOCR} "${FILE_PNG}" ${GCP_APIKEY}
	echo "gcv2hocr: ${FILE_JSON} ${FILE_HOCR}"
	${COMMAND_GCV2HOCR} "${FILE_JSON}" "${FILE_HOCR}"
	convert "${FILE_PNG}" "${TMP_DIR}/${FILE_PNG_FILENAME}.jpg"
done

# hocr+jpg -> pdf
echo "Generating: ${FILE_PDF_FILENAME}-ocr.pdf"
hocr-pdf "${TMP_DIR}/" > "${TMP_DIR}/${FILE_PDF_FILENAME}.pdf" # [3]
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/default -dNOPAUSE -dQUIET -dBATCH -sOutputFile="${FILE_PDF_FILENAME}-ocr.pdf" "${TMP_DIR}/${FILE_PDF_FILENAME}.pdf"
#cp -p "${TMP_DIR}/${FILE_PDF_FILENAME}.pdf" "${FILE_PDF_FILENAME}-ocr.pdf"

# cleanup
rm preout0.txt preout1.txt preout2.txt
rm -r "${TMP_DIR}"

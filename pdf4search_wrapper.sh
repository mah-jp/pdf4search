#!/bin/bash

# pdf4search_wrapper.sh (ver.20171018)
# Usage: cd SOMEDIR; pdf4search_wrapper.sh

# user's variables
DIR_OUTPUT=/path/to/save/
COMMAND_CONVERT=/path/to/pdf4search.sh
# variables
COMMAND_PDFTOTEXT=/usr/bin/pdftotext

for FILE_PDF in $( find . -type f -name '*.pdf' | sort ); do
	FILE_PDF_LOCK="${FILE_PDF}.lock"
	if [ ! -e "${FILE_PDF_LOCK}" ]; then
		echo "${FILE_PDF}"
		touch "${FILE_PDF_LOCK}"
		${COMMAND_CONVERT} "${FILE_PDF}"
		FILE_PDF_FILENAME="${FILE_PDF%.pdf}"
		mv "${FILE_PDF_FILENAME}.pdf" "${FILE_PDF_FILENAME}.pdf.bak"
		${COMMAND_PDFTOTEXT} "${FILE_PDF_FILENAME}-ocr.pdf"
#		mv "${FILE_PDF_FILENAME}-ocr.pdf" "${DIR_OUTPUT}"
		cp -p "${FILE_PDF_FILENAME}-ocr.pdf" "${DIR_OUTPUT}"
		rm "${FILE_PDF_LOCK}"
	fi
done

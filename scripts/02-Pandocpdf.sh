#!/bin/bash
#
# Usage:       Gets the input temp file from 01 script and converts it to the pdf.
#
# Description: Converts .md files into .pdf files by processing them through Pandoc.
#
#
INPUT_FILES=${1}
OUTPUT_PATH=${2}

# Convert the file from .md to .pdf
echo "pandoc --toc --pdf-engine=xelatex --resource-path=./pages ./templates/style.yaml ${INPUT_FILES} -o ${OUTPUT_PATH}.pdf --listings -H ./templates/listings-setup.tex  --biblatex --template=./templates/mesosphere.latex"
iconv -t utf-8 "${INPUT_FILES}" | pandoc  \
    --from=markdown_github+yaml_metadata_block \
    --toc \
    --highlight-style=zenburn \
    --listings \
    --pdf-engine=xelatex \
    --resource-path=./pages \
    --listings \
    --template=./templates/mesosphere.latex \
    -o "${OUTPUT_PATH}".pdf
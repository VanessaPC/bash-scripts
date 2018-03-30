#!/bin/bash
#
# Usage:       It will convert any markdown into a pdf. The markdown must be in a folder,
#              The markdown can be in a folder with any number of subfolders in it.
#
# Description: Sends files to Pandoc for conversion with the intention of getting a final pdf as a result.
#
# Packages: You will need Parallel, and Pandoc.
#

set -o errexit -o nounset -o pipefail

INPUT_FOLDER=${1}
OUTPUT_FOLDER=${2}
PARALLEL_TEMPFILE=$(mktemp)

TEMP_FILES=""

GREEN='\033[0;32m'
BLUE='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

function clean
{
    rm -rf "${1}"
    rm -f "${PARALLEL_TEMPFILE}"
}
echo "Started pdf Pandoc build $(date)"

function main
{
   # cd $INPUT_FOLDER
   while IFS= read -r -d '' SOURCE_FILE
   do
     # Strip the input_folder from filepath, not to include it within output folder and Destination filename
     local FILE_PATH=${SOURCE_FILE#$INPUT_FOLDER}
     # Strip the filename and get only the full directory path for the file
     local FILE_PATH="${FILE_PATH%/*}"
     # Strip the first / or ./ from the beginning of file path
     local FILE_PATH="${FILE_PATH#*/}"
     # Destination directory for pdf file
     local PDF_DEST_DIR="${OUTPUT_FOLDER}"/"${FILE_PATH}"
     # Remove INPUT_FOLDER from filename
     local PDF_FILE_NAME="${SOURCE_FILE#$INPUT_FOLDER}"
     # Remove leading ./ or / from filename, as find will output files with leading ./ or /
     local PDF_FILE_NAME="${PDF_FILE_NAME#*/}"
     # Replace all "/" characters in filename to "-" and append .pdf
     local PDF_FILE_NAME="${FILE_PATH//\//-}"
     # Change file extension from .html to .pdf
     local PDF_FILE_NAME="${PDF_FILE_NAME/%.md/.pdf}"
     # local RESOURCE_PATH="$"
     # echo "$PDF_FILE_NAME" "file name"
     # For example if SOURCE_FILE=./build/1.10/cli/dcos-marathon-group-scale-index.html
     # PDF_FILE_NAME will be 1.10-cli-dcos-marathon-group-scale-index.html.p
     # Make the Destination directory
     mkdir -p "${PDF_DEST_DIR}"

     # There is an index.md whithing every file
     FILE_NAME="index.md"
     TEMP_FILE=$(mktemp)

    # echo "find ${INPUT_FOLDER}/${FILE_PATH} -type d -depth"
    # echo file -I "${FILE_PATH}"
    # done=0

    # We find the index.md per folder so the final pdf is organised per folder not natively recursive
    while IFS= read -r SOURCE_FOLDERS
      do
        # Target all the folder names
        local d="$SOURCE_FOLDERS"
        # Target all the files whithin the foler by the same name
        NEW_FILE="${d}/${FILE_NAME}"
        # Target the title in metadata to introduce them as h1 in the documents
        while read -r MARKDOWN_SOURCE;
        do
          if [[ "${MARKDOWN_SOURCE}" =~ title:[[:space:]]([ a-zA-Z0-9]*) ]]; then
            TITLE="${BASH_REMATCH[1]}"
            echo "" >> "${TEMP_FILE}"
            echo "# $TITLE" >> "${TEMP_FILE}"
            echo "" >> "${TEMP_FILE}"
            # "${done}"=1
          fi
          # I purposely break out of the loop so I dont loop through all the lines, I know title will be in the metadata
          # if [ "{$done}" -ne 0 ]; then
          #   break
          # fi
        done < "${NEW_FILE}"

        if [ -f "${NEW_FILE}" ]
        then


          # Create temporary file with all md content to send to pandoc
          # this avoids very long urls & long strings (Pandoc has a string limit)
          TEMP_FILES="${TEMP_FILES} ${TEMP_FILE}"
          echo "" >> "${TEMP_FILE}"

          cat "${NEW_FILE}" >> "${TEMP_FILE}"
        fi
      # Find recursively all the directories whithin a folder
      done < <(find "${INPUT_FOLDER}"/"${FILE_PATH}" -type d -depth)

    # Set name for last folder
    if [ -z "${PDF_FILE_NAME}" ]
    then
      PDF_DEST_DIR=''
      PDF_FILE_NAME="MesosphereDCOS"
    fi

    # Pandoc gets the string of files and outputs the pdf.
    echo "scripts/pandocpdf.sh ${TEMP_FILE} ${PDF_DEST_DIR}/${PDF_FILE_NAME}" >> "${PARALLEL_TEMPFILE}"


   done <  <(find "${INPUT_FOLDER}" -type f -name "*.md" -print0)

  echo "Starting pdf build $(date)"
  cat "${PARALLEL_TEMPFILE}" | parallel --halt-on-error 2 --progress --eta --workdir "${PWD}" --jobs "${PARALLEL_JOBS:-6}"
  echo "Finished build $(date)"
}

clean "${OUTPUT_FOLDER}"
main "${INPUT_FOLDER}" "${OUTPUT_FOLDER}"

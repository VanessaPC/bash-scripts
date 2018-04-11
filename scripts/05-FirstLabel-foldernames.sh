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

LOG="./test/01-test/index.md
./test/02-test/index.md
./test/02-test/index.md
.services/01-test/test/index.md"

INPUT_FOLDER=${1}
CHANGED_FILES=${LOG}

TEST_DIR="./test/"
FINAL_PATH=""
ALL_FOLDERS=""
# Function to determine which version need to be built
function selectFolder
{
    # Check if changed files is not empty
    if [[ ! -z "${CHANGED_FILES}" ]]
    then
        # substitute all spaces with a broken line
        # "/path/to/file /path/to/file2 /path/to/file3 /path/to/file4 /path/to/file5"\ | tr " " "\n"
        NEW_PATH=$(echo "${CHANGED_FILES}"\ | tr " " "\n")
        # loop through each line
        # remove the test directory
        for i in ${NEW_PATH}
        do
            echo "$i" " this is i"
            local path="${i#$TEST_DIR}"
            FINAL_PATH="$FINAL_PATH $(echo "${path}" \ | tr " " "\\n")"

            ALL_FOLDERS="$ALL_FOLDERS $(echo "$path"  | head -n1 | cut -d "/" -f1)"

        done

        # This is going to output all final paths
        FINAL_PATH=$(echo "${FINAL_PATH}"\ | tr " " "\\n")
        echo "${FINAL_PATH}" "this is final path"
        # push the first part of the word into this variable
        ALL_DIRECTORIES=$(echo "$ALL_FOLDERS" | tr ' ' '\n' | sort | uniq)

    # Otherwise, set it to build the entire ./test directory
    else
        INPUT_FOLDER="${TEST_DIR}"
    fi
}

selectFolder "${CHANGED_FILES}" "${TEST_DIR}"
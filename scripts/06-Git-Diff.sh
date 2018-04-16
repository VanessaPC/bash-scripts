#!/bin/bash
#
# Usage:       Gets saved jenkins screenshot of the previous git and makes a difference between whats there and whats in the new one
#
# Description: Gets a git diff from the previous build and the one that is about to happen to show all the changes
#
#
LOG=$(git diff "${GIT_PREVIOUS_SUCCESSFUL_COMMIT}"..HEAD --name-only)

# Use grep to filter any result by insterting the extension of the file or name
LOG=$(git diff "${GIT_PREVIOUS_SUCCESSFUL_COMMIT}"..HEAD --name-only  | grep .md)


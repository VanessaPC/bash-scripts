#!/bin/bash
#
# Usage:       Cuts any string by 180 char which is mostly supported.
#
#
#

YOUR_FILE=$1

# We cut all long strings at 180 characters.
sed -i -r 's/.{180}/&\n/g' "${YOUR_FILE}"
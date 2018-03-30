#!/bin/bash
#
# Usage:       Encode any non-utf8 character
#
#
#


 # Unicode characters to encode into UTF8.
 CHARS=$(python -c 'print u"\u2060\u0080\u0099\u009C\u009d\u0098\u0094\<add any nonutf8.".encode("utf8" )')
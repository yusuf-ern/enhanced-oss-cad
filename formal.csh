#!/bin/csh
# csh/tcsh wrapper for sva2sby.
# Usage: source this file or place it on your PATH as 'sva2sby.csh'.

set SCRIPT_DIR = `dirname $0`
set SCRIPT_DIR = `cd "$SCRIPT_DIR" && pwd`
exec python3 "${SCRIPT_DIR}/tools/formal.py" $argv:q

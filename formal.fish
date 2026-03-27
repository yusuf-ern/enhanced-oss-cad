#!/usr/bin/env fish
# Fish shell wrapper for sva2sby.
# Usage: source this file or place it on your fish PATH as 'sva2sby.fish'.

set -l SCRIPT_DIR (cd (dirname (status filename)); and pwd)
exec python3 "$SCRIPT_DIR/tools/formal.py" $argv

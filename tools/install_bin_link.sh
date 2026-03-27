#!/bin/sh
# Install sva2sby wrappers for multiple shells.
# Creates the main symlink and optional fish/csh wrappers.
set -eu

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_DIR="${1:-/tool/formal_tools/oss-cad-suite/bin}"
TARGET_NAME="${2:-sva2sby}"

mkdir -p "${TARGET_DIR}"

# Main POSIX sh wrapper (works with bash, zsh, dash, ksh, etc.)
ln -sfn "${ROOT}/formal" "${TARGET_DIR}/${TARGET_NAME}"
echo "Installed ${TARGET_DIR}/${TARGET_NAME} -> ${ROOT}/formal  (sh/bash/zsh/dash/ksh)"

# Fish shell wrapper
if [ -f "${ROOT}/formal.fish" ]; then
    ln -sfn "${ROOT}/formal.fish" "${TARGET_DIR}/${TARGET_NAME}.fish"
    echo "Installed ${TARGET_DIR}/${TARGET_NAME}.fish -> ${ROOT}/formal.fish  (fish)"
fi

# csh/tcsh wrapper
if [ -f "${ROOT}/formal.csh" ]; then
    ln -sfn "${ROOT}/formal.csh" "${TARGET_DIR}/${TARGET_NAME}.csh"
    echo "Installed ${TARGET_DIR}/${TARGET_NAME}.csh -> ${ROOT}/formal.csh  (csh/tcsh)"
fi

echo ""
echo "Shell support:"
echo "  sh/bash/zsh/dash/ksh : ${TARGET_NAME}"
echo "  fish                 : ${TARGET_NAME}.fish  (or: source ${TARGET_NAME}.fish)"
echo "  csh/tcsh             : ${TARGET_NAME}.csh   (or: source ${TARGET_NAME}.csh)"

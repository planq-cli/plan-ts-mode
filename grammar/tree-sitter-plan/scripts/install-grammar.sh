#!/usr/bin/env bash
# Install the Plan grammar into Emacs' standard treesit search directory.
#
# Emacs treesit looks in <user-emacs-directory>/tree-sitter (default
# ~/.emacs.d/tree-sitter) and in directories listed in `treesit-extra-load-path`.
# We install to ~/.emacs.d/tree-sitter unless TREESIT_DIR overrides it. This copies
# an already-built shared library; it never downloads or compiles a grammar.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
grammar_dir="$(cd "$here/.." && pwd)"
repo_root="$(cd "$grammar_dir/../.." && pwd)"

case "$(uname -s)" in
  Darwin) extension="dylib" ;;
  Linux) extension="so" ;;
  *)
    echo "error: unsupported platform $(uname -s); use macOS or Linux" >&2
    exit 1
    ;;
esac

library="$repo_root/target/tree-sitter/libtree-sitter-plan.$extension"
dest_dir="${TREESIT_DIR:-$HOME/.emacs.d/tree-sitter}"
dest="$dest_dir/libtree-sitter-plan.$extension"
tmp="${dest}.tmp.$$"

if [[ ! -f "$library" ]]; then
  echo "error: $library not found; run scripts/build-dylib.sh first" >&2
  exit 1
fi

mkdir -p "$dest_dir"
trap 'rm -f "$tmp"' EXIT
cp "$library" "$tmp"
if [[ "$(uname -s)" == "Darwin" ]]; then
  codesign --force --sign - "$tmp"
  codesign --verify --verbose=2 "$tmp"
fi
mv -f "$tmp" "$dest"
trap - EXIT
echo "installed libtree-sitter-plan.$extension -> $dest_dir"

#!/usr/bin/env bash
# Build the platform tree-sitter shared library from the generated C parser.
#
# Reproducible: compiles only the generated src/parser.c (which bundles its own
# tree_sitter/*.h runtime headers) into a shared library. No implicit download or
# grammar regeneration happens here - run `npm run generate` explicitly if
# grammar.js changed.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
grammar_dir="$(cd "$here/.." && pwd)"
repo_root="$(cd "$grammar_dir/../.." && pwd)"

src="$grammar_dir/src/parser.c"
out_dir="$repo_root/target/tree-sitter"

case "$(uname -s)" in
  Darwin)
    extension="dylib"
    linker_flag="-dynamiclib"
    ;;
  Linux)
    extension="so"
    linker_flag="-shared"
    ;;
  *)
    echo "error: unsupported platform $(uname -s); use macOS or Linux" >&2
    exit 1
    ;;
esac

out="$out_dir/libtree-sitter-plan.$extension"

if [[ ! -f "$src" ]]; then
  echo "error: $src not found; run 'npm run generate' in $grammar_dir first" >&2
  exit 1
fi

cc="${CC:-cc}"
mkdir -p "$out_dir"

# -I src so parser.c finds its bundled tree_sitter/parser.h; the grammar has no
# external scanner, so parser.c is the only translation unit.
"$cc" -O2 -fPIC -std=c11 \
  -I "$grammar_dir/src" \
  "$linker_flag" \
  -o "$out" \
  "$src"

echo "wrote $out"

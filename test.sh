#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
grammar="$root/grammar/tree-sitter-plan"
grammar_dir="$(mktemp -d)"
home_dir="$(mktemp -d)"
trap 'rm -rf "$grammar_dir" "$home_dir"' EXIT

case "$(uname -s)" in
  Darwin) extension="dylib" ;;
  Linux) extension="so" ;;
  *)
    echo "error: unsupported platform $(uname -s); use macOS or Linux" >&2
    exit 1
    ;;
esac

(
  cd "$grammar"
  HOME="$home_dir" \
    npm_config_cache="$home_dir/.npm-cache" \
    npm_config_userconfig="$home_dir/.npmrc" \
    npm ci
  HOME="$home_dir" \
    npm_config_cache="$home_dir/.npm-cache" \
    npm_config_userconfig="$home_dir/.npmrc" \
    npm test
)
"$grammar/scripts/build-dylib.sh"

library="$root/target/tree-sitter/libtree-sitter-plan.$extension"
cp "$library" "$grammar_dir/libtree-sitter-plan.$extension"

HOME="$home_dir" emacs -Q --batch \
  --eval "(setq treesit-extra-load-path (list \"$grammar_dir/\"))" \
  -L "$root" \
  -l "$root/plan-ts-mode.el" \
  -l "$root/emacs/plan-ts-mode-tests.el" \
  -f ert-run-tests-batch-and-exit

HOME="$home_dir" emacs -Q --batch \
  -L "$root" \
  --eval "(progn (byte-compile-file \"$root/plan-ts-mode.el\") (kill-emacs 0))"
rm -f "$root/plan-ts-mode.elc"

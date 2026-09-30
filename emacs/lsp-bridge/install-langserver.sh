#!/usr/bin/env bash
# Install the `plan` lsp-bridge langserver config into the user's EXISTING
# `lsp-bridge-user-langserver-dir`.
#
# This copies emacs/lsp-bridge/plan.json into the directory that variable already
# points at. It MUST NOT redirect `lsp-bridge-user-langserver-dir` to this repo,
# which would shadow the user's other server configs. Enabling the LSP is a
# separate, opt-in step (see emacs/lsp-bridge/README.md); installing this file
# never enables lsp-bridge and never edits the user's Emacs config.
#
# Resolution order for the destination directory:
#   1. LSP_BRIDGE_USER_LANGSERVER_DIR env var (explicit override), else
#   2. the value of `lsp-bridge-user-langserver-dir` from a batch Emacs that has
#      lsp-bridge loaded, else
#   3. exit with an actionable hint (do not guess a path).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/plan.json"

if [[ ! -f "$src" ]]; then
  echo "error: $src not found" >&2
  exit 1
fi

dest_dir="${LSP_BRIDGE_USER_LANGSERVER_DIR:-}"

if [[ -z "$dest_dir" ]]; then
  emacs="${EMACS:-emacs}"
  # Ask the user's own Emacs where its lsp-bridge user langserver dir is. We only
  # read the variable; we never set it. Empty output means lsp-bridge is not set
  # up, in which case we refuse to guess.
  dest_dir="$("$emacs" --batch --eval \
    '(progn (ignore-errors (require (quote lsp-bridge)))
            (princ (or (and (boundp (quote lsp-bridge-user-langserver-dir))
                            lsp-bridge-user-langserver-dir) "")))' \
    2>/dev/null || true)"
fi

if [[ -z "$dest_dir" ]]; then
  cat >&2 <<'EOF'
error: could not determine `lsp-bridge-user-langserver-dir`.
Install lsp-bridge and set that variable, or run again with an explicit path:

  LSP_BRIDGE_USER_LANGSERVER_DIR=/path/to/langserver \
    emacs/lsp-bridge/install-langserver.sh

This installs only the `plan` server config; it does not enable lsp-bridge or
change any Emacs variable.
EOF
  exit 1
fi

mkdir -p "$dest_dir"
cp "$src" "$dest_dir/plan.json"
echo "installed plan.json -> $dest_dir"
echo "next: enable it per emacs/lsp-bridge/README.md (opt-in; not automatic)"

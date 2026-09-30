# Optional lsp-bridge integration

`plan-ts-mode` does not require lsp-bridge. Highlighting, indentation, comments,
navigation, and imenu work with Emacs' built-in tree-sitter support.

This directory connects the `planq lsp` stdio server to an existing lsp-bridge
installation. Installing the configuration does not enable lsp-bridge or change
global Emacs variables.

## Install the server configuration

The script copies `plan.json` into the directory already configured by
`lsp-bridge-user-langserver-dir`:

```bash
emacs/lsp-bridge/install-langserver.sh
```

You can provide the destination explicitly:

```bash
LSP_BRIDGE_USER_LANGSERVER_DIR=~/.emacs.d/lsp-bridge/langserver \
  emacs/lsp-bridge/install-langserver.sh
```

The `planq` executable must be on `PATH`. The server command is
`["planq", "lsp"]`.

## Enable the integration

Add this opt-in configuration:

```elisp
(require 'plan-ts-mode)

(with-eval-after-load 'lsp-bridge
  (add-to-list 'lsp-bridge-default-mode-hooks 'plan-ts-mode-hook)
  (add-to-list 'lsp-bridge-single-lang-server-mode-list
               '(plan-ts-mode . "plan")))
```

Plan buffers then support diagnostics, completion, hover, definitions,
references, rename, and formatting. The mode adjusts the completion predicate
only in Plan buffers so value completion can appear after a field's separating
space.

`support-single-file` is false because `planq lsp` resolves includes and project
resources from the PlanQ project root. Restart the language server after
upgrading the `planq` executable.

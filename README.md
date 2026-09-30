# PlanQ mode for Emacs

`plan-ts-mode` is the official Emacs major mode for PlanQ `.plan` files. It
provides tree-sitter highlighting, structural indentation, comments, navigation,
and imenu on Emacs 29.1 or later.

The mode works without an LSP client. The optional `planq lsp` integration adds
diagnostics, completion, hover, definitions, references, rename, and formatting.

## Install the mode

Evaluate this once in Emacs:

```elisp
(require 'package)
(package-vc-install "https://github.com/planq-cli/plan-ts-mode")
```

Then add:

```elisp
(require 'plan-ts-mode)
```

Opening a `.plan` file now selects `plan-ts-mode`. The mode still opens files
when the grammar is missing and displays a link to the installation steps below.

## Install the tree-sitter grammar

The build uses the committed generated parser. Opening a `.plan` file never
downloads or compiles code.

```bash
git clone --depth 1 --branch v1.0.0 \
  https://github.com/planq-cli/plan-ts-mode.git
cd plan-ts-mode/grammar/tree-sitter-plan
scripts/build-dylib.sh
scripts/install-grammar.sh
```

The scripts support macOS and Linux. Set `CC` to choose a C compiler or
`TREESIT_DIR` to override Emacs' default `~/.emacs.d/tree-sitter` destination.
Restart Emacs after installing the grammar.

Verify the setup:

```elisp
(treesit-ready-p 'plan t)       ; => t
(locate-library "plan-ts-mode") ; => installed package path
```

## Format on save

`plan-ts-mode` runs the matching PlanQ stdin formatter before save. Install
`planq` separately and keep it on `PATH`, or configure its path:

```elisp
(setq plan-ts-mode-plan-command "/path/to/planq")
```

To disable formatting for one buffer:

```elisp
(setq-local plan-ts-mode-format-on-save nil)
```

See [PlanQ installation](https://planq.dev/docs/install) for CLI packages.

## Optional `planq lsp`

The mode does not require lsp-bridge. To opt into LSP features, install PlanQ
and follow [`emacs/lsp-bridge/README.md`](emacs/lsp-bridge/README.md).

## Troubleshooting

- Grammar unavailable: rerun both grammar scripts, restart Emacs, and evaluate
  `(treesit-ready-p 'plan t)`.
- `planq` not found while saving: install the CLI, adjust `exec-path`, set
  `plan-ts-mode-plan-command`, or disable format on save for that buffer.
- LSP unavailable: run `planq version`, then `planq lsp` from a terminal to
  verify the executable before checking the optional lsp-bridge configuration.

## Development

Run all public mode and grammar tests:

```bash
./test.sh
```

`plan-ts-mode.el` is licensed under GPL-3.0-or-later. The grammar under
`grammar/tree-sitter-plan/` is licensed separately under MIT.

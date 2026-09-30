# tree-sitter-plan

Plan DSL v1 (`.plan`) tree-sitter grammar for Emacs `treesit` incremental
highlighting, structural navigation and indentation. This directory is shipped
with [`plan-ts-mode`](https://github.com/planq-cli/plan-ts-mode).

The grammar performs **no** semantic validation. It accepts DSL v1 reserved
forms (`(...)` and bare numbers) as `reserved`; whether a form is allowed is
decided solely by the PlanQ analysis pipeline. PlanQ remains the authority for
semantics and IR.

## Layout

- `grammar.js` — grammar definition (source of truth)
- `src/parser.c`, `src/node-types.json` — generated, committed
- `queries/highlights.scm` — highlight captures
- `test/corpus/` — node-tree goldens (valid / reserved / trivia / incomplete)
- `test/highlight/` — highlight capture goldens
- `scripts/build-dylib.sh` - compile the committed C parser to a shared library
- `scripts/install-grammar.sh` - install the library into Emacs' treesit dir

Platform dynamic libraries are **not** committed (see `.gitignore`).

## Reproducible build

```sh
npm install                       # pinned tree-sitter-cli (dev only)
npm run generate                  # regenerate src/parser.c after editing grammar.js
npm test                          # run corpus + highlight goldens

scripts/build-dylib.sh            # build .dylib on macOS or .so on Linux
scripts/install-grammar.sh        # install into ~/.emacs.d/tree-sitter
```

`build-dylib.sh` compiles only the committed `src/parser.c` (which bundles its
own `tree_sitter/*.h`); it never downloads or regenerates the grammar.
`install-grammar.sh` copies an already-built library into Emacs' standard
treesit directory (`TREESIT_DIR` overrides the destination). Neither script does
implicit network access or compilation on the file-open path.

## License

MIT. See [`LICENSE`](LICENSE).

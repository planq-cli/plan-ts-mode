; Highlight captures for tree-sitter-plan (Plan DSL v1).
;
; Node names match the Clojure lossless CST. These captures are consumed by the
; golden highlight test and by editors that read tree-sitter highlight queries;
; Emacs plan-ts-mode declares equivalent faces via treesit font-lock rules.

; field name after the ':' (e.g. :title, :task, :after)
(field (identifier) @property)

; bare scalar values / references. Domain tooling applies field-aware semantics.
(pair (plain_scalar) @variable)
(vector (plain_scalar) @variable)
(id_reference) @variable

(string) @string
(multiline) @string.special

; Include paths are source-owned file references, distinct from display strings.
((pair
  (field (identifier) @property)
  (string) @string.special)
 (#eq? @property "include"))

(comment) @comment

; reserved forms are accepted syntactically; colour them distinctly so authors
; can see them, while Clojure emits the syntax/reserved diagnostic.
(paren) @constant

["{" "}" "[" "]"] @punctuation.bracket
":" @punctuation.delimiter

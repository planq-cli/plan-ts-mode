;;; plan-ts-mode.el --- Major mode for Plan DSL v1 (.plan) -*- lexical-binding: t; -*-

;; Author: Jinwei Tang <jinwei233@users.noreply.github.com>
;; Maintainer: Jinwei Tang <jinwei233@users.noreply.github.com>
;; Version: 1.0.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: languages, tools
;; URL: https://github.com/planq-cli/plan-ts-mode
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; A tree-sitter major mode for editing Plan DSL v1 (`.plan') files.  It depends
;; only on the built-in `treesit' library (Emacs 29.1+) and never requires an
;; LSP client: syntax highlighting, `//' comments, structural indentation,
;; navigation and imenu all work standalone.  When the `plan' tree-sitter grammar
;; is not installed the mode still opens the file (no error), shows an actionable
;; install hint and simply skips treesit setup.
;;
;; Optional LSP features are provided separately by `planq lsp' via lsp-bridge
;; (see emacs/lsp-bridge/).  This file never requires lsp-bridge; when it is
;; already loaded, Plan buffers adjust one completion predicate buffer-locally
;; so value candidates can appear after a field's separating space.
;;
;; Node names match the shared grammar / Clojure CST:
;;   document map pair field vector identifier plain_scalar string multiline
;;   comment reserved paren

;;; Code:

(require 'treesit)
(require 'json)

(defgroup plan-ts nil
  "Major mode for Plan DSL v1 files."
  :group 'languages
  :prefix "plan-ts-")

(defcustom plan-ts-mode-plan-command "planq"
  "Plan CLI executable used for synchronous format-on-save."
  :type 'string
  :group 'plan-ts)

(defcustom plan-ts-mode-format-on-save t
  "When non-nil, canonicalize the current buffer before saving.
The formatter is invoked synchronously with the buffer's absolute source path."
  :type 'boolean
  :group 'plan-ts)

(make-variable-buffer-local 'plan-ts-mode-format-on-save)
(put 'plan-ts-mode-format-on-save 'safe-local-variable #'booleanp)

(defvar-local plan-ts-mode--formatting nil
  "Non-nil while the current buffer is running format-on-save.")

(defun plan-ts-mode--resource-document-p ()
  "Return non-nil when the current buffer is the project resource document."
  (and buffer-file-name
       (string-equal (file-name-nondirectory buffer-file-name)
                     "resources.plan")))

(defun plan-ts-mode--format-arguments ()
  "Return the canonical formatter arguments for the current Plan document."
  (if (plan-ts-mode--resource-document-p)
      '("resources" "format" "--stdin")
    (append '("format" "--stdin" "--source-path")
            (list (expand-file-name buffer-file-name)))))

(defun plan-ts-mode--configure-lsp-bridge-completion ()
  "Allow LSP value completion after whitespace in the current Plan buffer.
lsp-bridge normally suppresses completion whenever the character before point
is blank.  Plan values necessarily follow a separating space, so remove only
that generic predicate from this buffer and leave every other mode unchanged."
  (when (boundp 'lsp-bridge-completion-popup-predicates)
    (set (make-local-variable 'lsp-bridge-completion-popup-predicates)
         (delq 'lsp-bridge--not-only-blank-before-cursor
               (copy-sequence
                (symbol-value
                 'lsp-bridge-completion-popup-predicates))))))

(defun plan-ts-mode--format-error-message (payload)
  "Return a short formatter error extracted from JSON PAYLOAD."
  (let* ((diagnostics (and payload (gethash "diagnostics" payload)))
         (first (and (vectorp diagnostics) (> (length diagnostics) 0)
                     (aref diagnostics 0))))
    (or (and first (gethash "reason" first))
        "canonicalization failed")))

(defun plan-ts-mode--window-state ()
  "Capture viewport state for live windows displaying the current buffer."
  (mapcar (lambda (window)
            (list window
                  (copy-marker (window-start window))
                  (window-hscroll window)
                  (window-vscroll window t)))
          (get-buffer-window-list (current-buffer) nil t)))

(defun plan-ts-mode--restore-window-state (states)
  "Restore viewport STATES captured by `plan-ts-mode--window-state'."
  (dolist (state states)
    (pcase-let ((`(,window ,start ,hscroll ,vscroll) state))
      (when (window-live-p window)
        (set-window-start window (marker-position start) t)
        (set-window-hscroll window hscroll)
        (set-window-vscroll window vscroll t))
      (set-marker start nil)))
  (let ((window (get-buffer-window (current-buffer))))
    (when (window-live-p window)
      (set-window-point window (point))
      (when (not (pos-visible-in-window-p (point) window t))
        (set-window-start
         window
         (save-excursion
           (goto-char (point))
           (forward-line (- 2 (window-body-height window)))
           (line-beginning-position))
         t)
        (set-window-point window (point))))))

(defun plan-ts-mode--token-start-p (position)
  "Return non-nil when POSITION appears to be the start of source text."
  (and (< position (point-max))
       (not (memq (char-after position) '(?\s ?\t ?\n ?\r ?\} ?\])))
       (or (= position (point-min))
           (memq (char-before position)
                 '(?\s ?\t ?\n ?\r ?\{ ?\[ ?:)))))

(defun plan-ts-mode--replace-canonical-source (canonical)
  "Incrementally replace the current buffer with CANONICAL.
Markers, overlays and viewports follow unchanged text.  The replacement is one
atomic undo unit and any application error restores the complete original."
  (let ((source (current-buffer))
        (replacement (generate-new-buffer " *plan-canonical*"))
        (active-mark mark-active)
        (point-marker (copy-marker (point)
                                   (plan-ts-mode--token-start-p (point))))
        (saved-mark (when (mark t)
                      (copy-marker (mark t)
                                   (plan-ts-mode--token-start-p (mark t)))))
        (overlay-markers
         (mapcar (lambda (overlay)
                   (list overlay
                         (copy-marker (overlay-start overlay) t)
                         (copy-marker (overlay-end overlay) nil)))
                 (overlays-in (point-min) (point-max))))
        (deactivate-mark nil)
        (windows (plan-ts-mode--window-state)))
    (unwind-protect
        (progn
          (with-current-buffer replacement
            (insert canonical))
          (undo-boundary)
          (atomic-change-group
            (replace-region-contents (point-min) (point-max) replacement))
          (undo-boundary)
          (goto-char point-marker)
          (when saved-mark
            (set-mark (marker-position saved-mark)))
          (dolist (entry overlay-markers)
            (pcase-let ((`(,overlay ,start ,end) entry))
              (when (overlayp overlay)
                (move-overlay overlay start end source))))
          (setq mark-active active-mark)
          (plan-ts-mode--restore-window-state windows))
      (set-marker point-marker nil)
      (when saved-mark
        (set-marker saved-mark nil))
      (dolist (entry overlay-markers)
        (set-marker (nth 1 entry) nil)
        (set-marker (nth 2 entry) nil))
      (dolist (state windows)
        (set-marker (nth 1 state) nil))
      (when (buffer-live-p replacement)
        (kill-buffer replacement))
      (when (buffer-live-p source)
        (set-buffer source)))))

(defun plan-ts-mode--format-before-save ()
  "Canonicalize the current Plan document through the matching stdin formatter.
Failures are non-destructive: keep the original buffer and allow the save."
  (when (and plan-ts-mode-format-on-save
             (not plan-ts-mode--formatting))
    (save-restriction
      (widen)
      (if-let* ((program (executable-find plan-ts-mode-plan-command)))
          (let ((output (generate-new-buffer " *plan-format*"))
                (plan-ts-mode--formatting t))
            (unwind-protect
                (condition-case err
                    (let* ((coding-system-for-read 'utf-8-unix)
                           (coding-system-for-write 'utf-8-unix)
                           (status (apply
                                    #'call-process-region
                                    (point-min) (point-max)
                                    program nil output nil
                                    (plan-ts-mode--format-arguments)))
                           (payload
                            (with-current-buffer output
                              (goto-char (point-min))
                              (when (> (buffer-size) 0)
                                (json-parse-buffer))))
                           (result (and payload (gethash "result" payload)))
                           (canonical (and result (gethash "source" result))))
                      (if (and (zerop status) (stringp canonical))
                          (unless (equal canonical
                                         (buffer-substring-no-properties
                                          (point-min) (point-max)))
                            (plan-ts-mode--replace-canonical-source canonical))
                        (message "planq format: %s"
                                 (plan-ts-mode--format-error-message payload))))
                  (error
                   (message "planq format: %s" (error-message-string err))))
              (kill-buffer output)))
        (message "planq format: executable `%s' not found"
                 plan-ts-mode-plan-command)))))

;;;; Grammar availability

(defun plan-ts-mode--grammar-ready-p ()
  "Return non-nil when the `plan' tree-sitter grammar can be loaded."
  (and (fboundp 'treesit-available-p)
       (treesit-available-p)
       (treesit-ready-p 'plan t)))

(defun plan-ts-mode--install-hint ()
  "Return an actionable hint for installing the grammar."
  (concat "plan-ts-mode: tree-sitter grammar `plan' not found. "
          "Follow https://github.com/planq-cli/plan-ts-mode"
          "#install-the-tree-sitter-grammar"))

;;;; Font lock

(defvar plan-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'plan
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'plan
   :feature 'string
   '((string) @font-lock-string-face
     (multiline) @font-lock-doc-face)

   :language 'plan
   :feature 'keyword
   ;; the `:field' name after the colon reads like a keyword/property
   '((field (identifier) @font-lock-keyword-face))

   :language 'plan
   :feature 'variable
   ;; field-aware meaning is provided by diagnostics/LSP; tree-sitter preserves
   ;; every unquoted value as one plain scalar token.
   '((pair (plain_scalar) @font-lock-variable-name-face)
     (vector (plain_scalar) @font-lock-variable-use-face)
     (id_reference) @font-lock-variable-use-face)

   :language 'plan
   :feature 'bracket
   '(["{" "}" "[" "]"] @font-lock-bracket-face)

   :language 'plan
   :feature 'delimiter
   '(":" @font-lock-delimiter-face)

   :language 'plan
   :feature 'error
   :override t
   ;; reserved forms are syntactically accepted but flagged by Clojure; surface
   ;; parens distinctly so authors notice them.
   '((paren) @font-lock-warning-face))
  "`treesit-font-lock-settings' for `plan-ts-mode'.")

(defvar plan-ts-mode--font-lock-feature-list
  '((comment string)
    (keyword variable)
    (bracket delimiter)
    (error))
  "`treesit-font-lock-feature-list' for `plan-ts-mode' (four decoration levels).")

;;;; Indentation

;; Fixed two-column structural indentation that matches the formatter's canonical
;; layout.  There is deliberately no user-level indent width: the mode must not
;; introduce format drift, and `planq format' remains the normalization authority.

(defun plan-ts-mode--container-p (node)
  "Return non-nil when NODE is a structural map or vector."
  (and node (member (treesit-node-type node) '("map" "vector"))))

(defun plan-ts-mode--closing-delimiter-p (bol)
  "Return non-nil when the first character at BOL closes a container."
  (memq (char-after bol) '(?\} ?\])))

(defun plan-ts-mode--structural-depth (node parent bol)
  "Return the absolute map/vector depth for the line at BOL.
NODE is the largest node starting at BOL and PARENT is its parent.  Containers
whose opener starts on the current line are excluded, so a root or vector-item
opener stays at its outer depth.  A standalone closing delimiter also excludes
the container it closes."
  (let ((n (or node parent))
        (depth 0))
    (while n
      (when (and (plan-ts-mode--container-p n)
                 (< (treesit-node-start n) bol))
        (setq depth (1+ depth)))
      (setq n (treesit-node-parent n)))
    (when (and (> depth 0)
               (plan-ts-mode--closing-delimiter-p bol))
      (setq depth (1- depth)))
    depth))

(defun plan-ts-mode--structural-offset (node parent bol &rest _)
  "Return the fixed two-space indentation offset for the line at BOL."
  (* 2 (plan-ts-mode--structural-depth node parent bol)))

(defun plan-ts-mode--multiline-ancestor (node parent bol)
  "Return the multiline ancestor containing BOL, or nil."
  (let ((n (or node parent))
        (found nil))
    (while (and n (null found))
      (if (and (equal (treesit-node-type n) "multiline")
               (< (treesit-node-start n) bol))
          (setq found n)
        (setq n (treesit-node-parent n))))
    found))

(defun plan-ts-mode--multiline-ending-p (node parent bol &rest _)
  "Return non-nil when BOL is the closing backtick of a multiline value."
  (let ((multiline (plan-ts-mode--multiline-ancestor node parent bol)))
    (and multiline
         (= bol (1- (treesit-node-end multiline)))
         (eq (char-after bol) ?\`))))

(defun plan-ts-mode--in-multiline-p (node parent bol &rest _)
  "Matcher: non-nil when BOL falls inside a backtick multiline string.
The `multiline' node starts at its opening backtick, often mid-line, so a
`node-is' match never fires on its interior lines; treesit also passes NODE nil
there, so the walk starts from PARENT.  Look for a `multiline' ancestor that
began before BOL.  The ending backtick is handled by a higher-priority rule."
  (and (plan-ts-mode--multiline-ancestor node parent bol)
       (not (plan-ts-mode--multiline-ending-p node parent bol))))

(defun plan-ts-mode--keep-indent (_node _parent bol &rest _)
  "Anchor preserving the current indentation of the line at BOL.
Used inside backtick multiline strings so structural reindent never rewrites
their literal text content."
  (save-excursion (goto-char bol) (back-to-indentation) (point)))

(defvar plan-ts-mode--indent-rules
  `((plan
     ;; the closing backtick is structural and aligns with its field
     (plan-ts-mode--multiline-ending-p column-0
                                            plan-ts-mode--structural-offset)
     ;; never reflow literal text inside a backtick multiline string
     (plan-ts-mode--in-multiline-p plan-ts-mode--keep-indent 0)
     ;; all structure uses an absolute depth from column zero
     (catch-all column-0 plan-ts-mode--structural-offset)))
  "`treesit-simple-indent-rules' for `plan-ts-mode'.")

;;;; Navigation / imenu

(defun plan-ts-mode--defun-name (node)
  "Return the id of a task/milestone NODE for imenu / which-func."
  (when (equal (treesit-node-type node) "map")
    (let ((entity nil)
          (id nil))
      (dolist (pair (treesit-node-children node t))
        (when (equal (treesit-node-type pair) "pair")
          (let* ((field (treesit-node-child pair 0 t))
                 (fname (and field (treesit-node-text
                                    (treesit-node-child field 0 t) t)))
                 (value (treesit-node-child pair 1 t)))
            (when (member fname '("task" "milestone"))
              (setq entity t))
            (when (and (equal fname "id") value
                       (equal (treesit-node-type value) "plain_scalar"))
              (setq id (treesit-node-text value t))))))
      (and entity id))))

(defun plan-ts-mode--imenu-node-p (node)
  "Return non-nil when NODE is a task/milestone map worth listing in imenu."
  (and (equal (treesit-node-type node) "map")
       (plan-ts-mode--defun-name node)))

;;;; Mode definition

;;;###autoload
(define-derived-mode plan-ts-mode prog-mode "Plan"
  "Major mode for editing Plan DSL v1 (`.plan') files, powered by tree-sitter."
  :group 'plan-ts
  ;; `//' line comments — set up regardless of grammar so comment commands and
  ;; syntax-based fallbacks work even when the grammar is missing.
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "//+[ \t]*")
  (setq-local indent-tabs-mode nil)
  (modify-syntax-entry ?/ ". 12" (syntax-table))
  (modify-syntax-entry ?\n ">" (syntax-table))
  (modify-syntax-entry ?\` "\"" (syntax-table))
  (add-hook 'before-save-hook #'plan-ts-mode--format-before-save nil t)
  (plan-ts-mode--configure-lsp-bridge-completion)

  (if (not (plan-ts-mode--grammar-ready-p))
      ;; Graceful degradation: no parser, no error, actionable hint.
      (message "%s" (plan-ts-mode--install-hint))
    (treesit-parser-create 'plan)
    (setq-local treesit-font-lock-settings plan-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list plan-ts-mode--font-lock-feature-list)
    (setq-local treesit-simple-indent-rules plan-ts-mode--indent-rules)
    (setq-local treesit-defun-type-regexp
                (cons "map" #'plan-ts-mode--imenu-node-p))
    (setq-local treesit-defun-name-function #'plan-ts-mode--defun-name)
    (setq-local treesit-simple-imenu-settings
                `(("Task/Milestone" "\\`map\\'"
                   plan-ts-mode--imenu-node-p
                   plan-ts-mode--defun-name)))
    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.plan\\'" . plan-ts-mode))

(declare-function lsp-bridge-find-def "lsp-bridge")
(declare-function lsp-bridge-find-def-return "lsp-bridge")
(declare-function lsp-bridge-popup-documentation "lsp-bridge")
(declare-function lsp-bridge-find-references "lsp-bridge")
(declare-function lsp-bridge-format-buffer "lsp-bridge")

(define-key plan-ts-mode-map (kbd "M-.") #'lsp-bridge-find-def)
(define-key plan-ts-mode-map (kbd "M-,") #'lsp-bridge-find-def-return)
(define-key plan-ts-mode-map (kbd "C-c C-d") #'lsp-bridge-popup-documentation)
(define-key plan-ts-mode-map (kbd "C-c C-r") #'lsp-bridge-find-references)
(define-key plan-ts-mode-map (kbd "C-c C-f") #'lsp-bridge-format-buffer)

(provide 'plan-ts-mode)

;;; plan-ts-mode.el ends here

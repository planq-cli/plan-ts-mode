;;; plan-ts-mode-tests.el --- ERT batch tests for plan-ts-mode -*- lexical-binding: t; -*-

;;; Commentary:

;; Batch ERT tests for `plan-ts-mode'.  Runs headless and never touches the
;; user's real `~/.emacs.d': the grammar directory is provided through
;; `treesit-extra-load-path' (set by the runner, see scripts/emacs-ert.sh).
;; Verified on Emacs 30.2 while keeping to Emacs 29.1 APIs.

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'plan-ts-mode)

(ert-deftest plan-ts-explicit-reference-boundaries ()
  "Explicit references retain their whole token, including malformed IDs."
  (dolist (token '("@review" "@" "@person-" "@ID" "@张三"))
    (with-temp-buffer
      (insert (concat "{:after [" token "]}"))
      (plan-ts-mode)
      (goto-char (point-min))
      (search-forward "@")
      (let ((node (treesit-node-at (1- (point)))))
        (should (equal "id_reference" (treesit-node-type node)))
        (should (equal token (treesit-node-text node)))))))

(defvar plan-ts-tests--fixture-dir
  (expand-file-name "../tests/fixtures/plan/"
                    (file-name-directory (or load-file-name buffer-file-name)))
  "Directory holding shared `.plan' fixtures.")

(defvar plan-ts-tests--emacs-dir
  (file-name-directory (or load-file-name buffer-file-name))
  "The `emacs/' source directory, captured at load time.")

(defun plan-ts-tests--fixture (name)
  "Return the contents of fixture NAME."
  (with-temp-buffer
    (insert-file-contents (expand-file-name name plan-ts-tests--fixture-dir))
    (buffer-string)))

(defmacro plan-ts-tests--with-fixture (name &rest body)
  "Open fixture NAME in a `plan-ts-mode' buffer and run BODY."
  (declare (indent 1))
  `(with-temp-buffer
     (insert (plan-ts-tests--fixture ,name))
     (goto-char (point-min))
     (let ((buffer-file-name (expand-file-name ,name plan-ts-tests--fixture-dir)))
       (plan-ts-mode))
     ,@body))

(defun plan-ts-tests--format-as (canonical)
  "Run the real before-save hook path with mocked CANONICAL output."
  (cl-letf (((symbol-function 'executable-find) (lambda (_command) "/fake/planq"))
            ((symbol-function 'call-process-region)
             (lambda (_start _end _program _delete destination _display &rest _args)
               (with-current-buffer destination
                 (insert (json-encode
                          `(("result" . (("changed" . t)
                                         ("source" . ,canonical)))))))
               0)))
    (run-hooks 'before-save-hook)))

(ert-deftest plan-ts-auto-mode ()
  "Plan entries and `resources.plan' map to `plan-ts-mode'."
  (should (eq 'plan-ts-mode
              (cdr (assoc "x.plan" auto-mode-alist #'string-match-p))))
  (should (eq 'plan-ts-mode
              (cdr (assoc "resources.plan"
                          auto-mode-alist
                          #'string-match-p)))))

(ert-deftest plan-ts-mode-enters ()
  "Opening a `.plan' buffer enters `plan-ts-mode' with `//' comment syntax."
  (plan-ts-tests--with-fixture "valid.plan"
    (should (derived-mode-p 'plan-ts-mode))
    (should (equal comment-start "// "))))

(ert-deftest plan-ts-format-on-save-hook-is-buffer-local ()
  "Plan buffers install the canonical formatter without changing global hooks."
  (let ((global-before-save before-save-hook))
    (with-temp-buffer
      (let ((buffer-file-name "t.plan"))
        (plan-ts-mode))
      (should plan-ts-mode-format-on-save)
      (should (memq #'plan-ts-mode--format-before-save before-save-hook)))
    (should (equal global-before-save before-save-hook))))

(ert-deftest plan-ts-format-on-save-applies-stdin-result ()
  "A successful stdin formatter result replaces the buffer before save."
  (with-temp-buffer
    (setq buffer-file-name "t.plan")
    (plan-ts-mode)
    (insert "{:version \"1.0\" :id p :title \"P\" :items [{:task \"Build\"}]}")
    (let ((canonical (concat "{\n  :id p\n  :version 1.0\n"
                             "  :title P\n  :items [\n    {\n"
                             "      :id task-1\n      :task Build\n"
                             "    }\n  ]\n}\n"))
          (calls 0))
      (cl-letf (((symbol-function 'executable-find) (lambda (_command) "/fake/planq"))
                ((symbol-function 'call-process-region)
                 (lambda (_start _end _program _delete destination _display &rest args)
                   (setq calls (1+ calls))
                   (should
                    (equal args
                           (list "format" "--stdin" "--source-path"
                                 (expand-file-name "t.plan"))))
                   (with-current-buffer destination
                     (insert (json-encode
                              `(("result" . (("changed" . t)
                                             ("source" . ,canonical)))))))
                   0)))
        (plan-ts-mode--format-before-save)
        (should (equal canonical (buffer-string)))
        (plan-ts-mode--format-before-save)
        (should (= 2 calls))
        (should (equal canonical (buffer-string)))))))

(ert-deftest plan-ts-resource-format-on-save-uses-resource-formatter ()
  "`resources.plan' uses its dedicated formatter and is not treated as an entry."
  (with-temp-buffer
    (setq buffer-file-name "/project/resources.plan")
    (plan-ts-mode)
    (insert "{:version 1.0 :people []}")
    (let ((canonical "{\n  :version 1.0\n  :people []\n}\n"))
      (cl-letf (((symbol-function 'executable-find)
                 (lambda (_command) "/fake/planq"))
                ((symbol-function 'call-process-region)
                 (lambda (_start _end _program _delete destination _display
                          &rest args)
                   (should (equal args
                                  '("resources" "format" "--stdin")))
                   (with-current-buffer destination
                     (insert (json-encode
                              `(("result" . (("changed" . t)
                                             ("source" . ,canonical)))))))
                   0)))
        (plan-ts-mode--format-before-save)
        (should (equal canonical (buffer-string)))))))

(ert-deftest plan-ts-format-on-save-can-be-disabled ()
  "The buffer-local option disables process invocation."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{:version \"1.0\" :id p :title \"P\"}")
    (setq-local plan-ts-mode-format-on-save nil)
    (let ((called nil)
          (original (buffer-string)))
      (cl-letf (((symbol-function 'executable-find)
                 (lambda (_command) (setq called t) "/fake/planq")))
        (plan-ts-mode--format-before-save))
      (should-not called)
      (should (equal original (buffer-string))))))

(ert-deftest plan-ts-format-on-save-failure-preserves-source ()
  "Formatter errors and a missing executable never partially replace source."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{:version \"1.0\" :id p :title \"P\" :items [{:task \"Build\"}]}")
    (let ((original (buffer-string))
          (inhibit-message t))
      (cl-letf (((symbol-function 'executable-find) (lambda (_command) "/fake/planq"))
                ((symbol-function 'call-process-region)
                 (lambda (_start _end _program _delete destination _display &rest _args)
                   (with-current-buffer destination
                     (insert (json-encode
                              '(("diagnostics" . [(("reason" . "bad draft"))])
                                ("result" . (("changed" . :json-false)
                                             ("source" . nil)))))))
                   1)))
        (plan-ts-mode--format-before-save)
        (should (equal original (buffer-string))))
      (cl-letf (((symbol-function 'executable-find) (lambda (_command) nil)))
        (plan-ts-mode--format-before-save)
        (should (equal original (buffer-string)))))))

(ert-deftest plan-ts-format-on-save-point-follows-canonicalized-token ()
  "Point follows task text through ID insertion, reordering and scalar changes."
  (dolist (case
           '(("{:version 1.0 :id p :title P :items [{:task 新增任务}]}"
              "{\n  :id p\n  :version 1.0\n  :title P\n  :items [\n    {\n      :id task-1\n      :task 新增任务\n    }\n  ]\n}\n"
              "新增任务")
             ("{:version 1.0 :title P :id p :items [{:id t :task Build}]}"
              "{\n  :id p\n  :version 1.0\n  :title P\n  :items [\n    {\n      :id t\n      :task Build\n    }\n  ]\n}\n"
              "Build")
             ("{:version 1.0 :id p :title P :items [{:id t :task \"Build\"}]}"
              "{\n  :id p\n  :version 1.0\n  :title P\n  :items [\n    {\n      :id t\n      :task Build\n    }\n  ]\n}\n"
              "Build")))
    (pcase-let ((`(,draft ,canonical ,token) case))
      (with-temp-buffer
        (let ((buffer-file-name "t.plan"))
          (plan-ts-mode))
        (insert draft)
        (search-backward token)
        (goto-char (match-end 0))
        (plan-ts-tests--format-as canonical)
        (should (looking-back token (line-beginning-position)))))))

(ert-deftest plan-ts-format-on-save-distinguishes-repeated-task-names ()
  "Point on the second repeated name does not jump to the first task."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan")
          (draft "{:version 1.0 :id p :title P :items [{:task Same}{:task Same}]}")
          (canonical (concat "{\n  :id p\n  :version 1.0\n  :title P\n  :items [\n"
                             "    {\n      :id task-1\n      :task Same\n    }\n"
                             "    {\n      :id task-2\n      :task Same\n    }\n  ]\n}\n")))
      (plan-ts-mode)
      (insert draft)
      (search-backward "Same")
      (goto-char (match-end 0))
      (plan-ts-tests--format-as canonical)
      (should (looking-back "Same" (line-beginning-position)))
      (save-excursion
        (search-backward ":id")
        (should (looking-at ":id task-2"))))))

(ert-deftest plan-ts-format-on-save-preserves-mark-overlay-and-undo ()
  "Incremental formatting keeps marker state and forms one undo unit."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan")
          (draft "{:version 1.0 :id p :title P :items [{:task Build}]}")
          (canonical (concat "{\n  :id p\n  :version 1.0\n  :title P\n"
                             "  :items [\n    {\n      :id task-1\n"
                             "      :task Build\n    }\n  ]\n}\n")))
      (plan-ts-mode)
      (buffer-enable-undo)
      (insert draft)
      (goto-char (point-min))
      (search-forward "Build")
      (let* ((end (point))
             (start (- end (length "Build")))
             (overlay (make-overlay start end)))
        (set-mark end)
        (goto-char start)
        (setq mark-active t)
        (setq buffer-undo-list nil)
        (plan-ts-tests--format-as canonical)
        (should mark-active)
        (should (< (point) (mark)))
        (should (equal "Build"
                       (buffer-substring-no-properties (point) (mark))))
        (should (equal "Build"
                       (buffer-substring-no-properties
                        (overlay-start overlay) (overlay-end overlay))))
        (undo-only 1)
        (should (equal draft (buffer-string)))))))

(ert-deftest plan-ts-format-on-save-application-error-rolls-back ()
  "An error while applying canonical text leaves the draft intact."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan")
          (draft "{:version 1.0 :id p :title P}"))
      (plan-ts-mode)
      (insert draft)
      (let ((inhibit-message t))
        (cl-letf (((symbol-function 'executable-find) (lambda (_command) "/fake/planq"))
                  ((symbol-function 'call-process-region)
                   (lambda (_start _end _program _delete destination _display
                            &rest _args)
                     (with-current-buffer destination
                       (insert "{\"result\":{\"source\":\"changed\"}}"))
                     0))
                  ((symbol-function 'replace-region-contents)
                   (lambda (&rest _args)
                     (delete-region (point-min) (point-max))
                     (error "apply failed"))))
          (plan-ts-mode--format-before-save)))
      (should (equal draft (buffer-string))))))

(ert-deftest plan-ts-format-on-save-disabled-preserves-editor-state ()
  "Disabling format-on-save leaves text, point, mark and overlays untouched."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{:version 1.0 :id p :title P}")
    (goto-char 5)
    (set-mark 10)
    (setq mark-active t)
    (let ((overlay (make-overlay 3 8))
          (before (buffer-string)))
      (setq-local plan-ts-mode-format-on-save nil)
      (run-hooks 'before-save-hook)
      (should (equal before (buffer-string)))
      (should (= 5 (point)))
      (should (= 10 (mark)))
      (should (= 3 (overlay-start overlay)))
      (should (= 8 (overlay-end overlay))))))

(ert-deftest plan-ts-format-on-save-deleted-whitespace-falls-back-nearby ()
  "Point in removed whitespace stays at the nearest surviving field boundary."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan")
          (draft "{:version 1.0 :id p :title P      :items []}")
          (canonical "{\n  :id p\n  :version 1.0\n  :title P\n  :items []\n}\n"))
      (plan-ts-mode)
      (insert draft)
      (search-backward "      ")
      (forward-char 3)
      (plan-ts-tests--format-as canonical)
      (should (<= (line-beginning-position)
                  (point)
                  (line-end-position)))
      (should (or (looking-at "[[:space:]]*:items")
                  (looking-back ":title P" (line-beginning-position)))))))

(ert-deftest plan-ts-format-on-save-preserves-multiple-window-viewports ()
  "Every live window follows its prior content instead of jumping to the top."
  (save-window-excursion
    (let* ((buffer (get-buffer-create " *plan-window-test*"))
           (draft (mapconcat (lambda (i) (format "line-%02d" i))
                             (number-sequence 0 59) "\n"))
           (canonical (concat "generated-id\n" draft))
           first second second-anchor)
      (unwind-protect
          (progn
            (switch-to-buffer buffer)
            (erase-buffer)
            (setq buffer-file-name "t.plan")
            (plan-ts-mode)
            (insert draft)
            (setq first (selected-window)
                  second (split-window-below))
            (set-window-buffer second buffer)
            (goto-char (point-min))
            (forward-line 10)
            (set-window-start first (point))
            (goto-char (point-min))
            (forward-line 30)
            (set-window-start second (point))
            (setq second-anchor (buffer-substring-no-properties
                                 (line-beginning-position) (line-end-position)))
            (goto-char (point-min))
            (forward-line 15)
            (plan-ts-tests--format-as canonical)
            (should-not (= (window-start first) (point-min)))
            (should-not (= (window-start second) (point-min)))
            (should (equal second-anchor
                           (save-excursion
                             (goto-char (window-start second))
                             (buffer-substring-no-properties
                              (line-beginning-position) (line-end-position)))))
            (should (= (window-point first) (point)))
            (should (< (- (line-number-at-pos (point))
                          (line-number-at-pos (window-start first)))
                       (window-body-height first))))
        (when (buffer-live-p buffer)
          (kill-buffer buffer))))))

(ert-deftest plan-ts-format-on-save-hook-is-consistent-and-reentrant-safe ()
  "Repeated normal save hooks use one rule and nested formatting is ignored."
  (let ((draft "{:version 1.0 :id p :title P :items [{:task Build}]}")
        (canonical (concat "{\n  :id p\n  :version 1.0\n  :title P\n"
                           "  :items [\n    {\n      :id task-1\n"
                           "      :task Build\n    }\n  ]\n}\n"))
        positions)
    (dotimes (_ 2)
      (with-temp-buffer
        (let ((buffer-file-name "t.plan"))
          (plan-ts-mode))
        (insert draft)
        (search-backward "Build")
        (goto-char (match-end 0))
        (plan-ts-tests--format-as canonical)
        (push (point) positions)))
    (should (= (car positions) (cadr positions)))
    (with-temp-buffer
      (let ((buffer-file-name "t.plan"))
        (plan-ts-mode))
      (insert draft)
      (let ((plan-ts-mode--formatting t)
            (called nil))
        (cl-letf (((symbol-function 'executable-find)
                   (lambda (_command) (setq called t) "/fake/planq")))
          (run-hooks 'before-save-hook))
        (should-not called)
        (should (equal draft (buffer-string)))))))

(ert-deftest plan-ts-comment-command ()
  "`comment-region' uses `//' comments."
  (plan-ts-tests--with-fixture "valid.plan"
    (goto-char (point-min))
    (forward-line 3)                    ; a code line inside the map
    (let ((beg (line-beginning-position))
          (end (line-end-position)))
      (comment-region beg end)
      (goto-char beg)
      (should (looking-at "//")))))

(ert-deftest plan-ts-grammar-ready ()
  "The test environment provides the grammar (set up by the runner)."
  (should (plan-ts-mode--grammar-ready-p)))

(ert-deftest plan-ts-font-lock-parser ()
  "With the grammar present a `plan' parser is created for fontification."
  (plan-ts-tests--with-fixture "valid.plan"
    (should (treesit-parser-list nil 'plan))
    (font-lock-ensure)
    ;; the multiline `:description' value should carry a face
    (goto-char (point-min))
    (search-forward "作者端演示计划")
    (should (get-text-property (match-beginning 0) 'face))))

(ert-deftest plan-ts-font-lock-distinguishes-fields-and-plain-values ()
  "Field names, including `end', use keyword face rather than scalar face."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (insert "{:id task-1 :task 测试任务 :start 2026-09-02 :end 2026-09-11 :state done}")
      (plan-ts-mode)
      (font-lock-ensure)
      (dolist (field '("id" "task" "start" "end" "state"))
        (goto-char (point-min))
        (search-forward (concat ":" field))
        (should (eq (get-text-property (1- (point)) 'face)
                    'font-lock-keyword-face)))
      (dolist (value '("task-1" "测试任务" "2026-09-02" "2026-09-11" "done"))
        (goto-char (point-min))
        (search-forward value)
        (should (eq (get-text-property (match-beginning 0) 'face)
                    'font-lock-variable-name-face))))))

(ert-deftest plan-ts-imenu ()
  "imenu lists task/milestone ids from the document."
  (plan-ts-tests--with-fixture "valid.plan"
    (let* ((index (funcall imenu-create-index-function))
           (names nil))
      ;; imenu nests summary tasks with their children; collect every label,
      ;; both leaf entries (marker/integer position) and group headers.
      (cl-labels ((walk (node)
                    (cond
                     ((markerp (cdr node)) (push (car node) names))
                     ((integerp (cdr node)) (push (car node) names))
                     ((listp (cdr node))
                      (push (car node) names)
                      (mapc #'walk (cdr node))))))
        (mapc #'walk index))
      (should (member "design" names))
      (should (member "draft" names))
      (should (member "review" names))
      (should (member "design-done" names))
      (should (member "build" names)))))

(ert-deftest plan-ts-indent-pair-in-map ()
  "A fresh pair in a map indents two columns past the map's `{'."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{\n:id demo\n}")
    (goto-char (point-min))
    (forward-line 1)
    (indent-for-tab-command)
    (back-to-indentation)
    (should (= (current-column) 2))))

(ert-deftest plan-ts-indent-nested-map-in-vector ()
  "A pair inside a vector item map indents two columns past its `{'."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{\n  :items [\n    {\n:id inventory\n    }\n  ]\n}")
    (goto-char (point-min))
    (forward-line 3)
    (indent-for-tab-command)
    (back-to-indentation)
    (should (= (current-column) 6))))

(ert-deftest plan-ts-newline-after-inline-vector-item ()
  "A new line after an item map uses the inline vector's element depth."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{\n  :items [\n    {\n      :id build\n    }\n  ]\n}")
    (goto-char (point-min))
    (search-forward "\n    }")
    (end-of-line)
    (newline-and-indent)
    (should (= (current-column) 4))
    (should (looking-back "^    " (line-beginning-position)))))

(ert-deftest plan-ts-indent-structural-matrix ()
  "Inline containers and their delimiters use absolute structural depth."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert (concat "{\n"
                    "          :calendar {\n"
                    ":timezone \"UTC\"\n"
                    "}\n"
                    ":after [\n"
                    "prepare\n"
                    "]\n"
                    ":assignments [\n"
                    "{\n"
                    ":to alice\n"
                    "}\n"
                    "]\n"
                    "// assignment note\n"
                    "}\n"))
    (dolist (line-and-column
             '((2 . 4)
               (5 . 4)
               (6 . 2)
               (8 . 4)
               (9 . 6)
               (10 . 4)
               (12 . 2)))
      (goto-char (point-min))
      (forward-line (car line-and-column))
      (indent-for-tab-command)
      (back-to-indentation)
      (should (= (current-column) (cdr line-and-column))))
    ;; The parent remains deliberately misindented; child indentation is
    ;; absolute rather than relative to the parent's current screen column.
    (goto-char (point-min))
    (search-forward ":calendar")
    (beginning-of-line)
    (should (= (current-indentation) 10))
    (forward-line 1)
    (indent-region (line-beginning-position) (line-end-position))
    (should (= (current-indentation) 4))))

(ert-deftest plan-ts-indent-region-is-structural-and-idempotent ()
  "Whole-buffer indentation matches the two-space structural layout."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert (concat "{\n"
                    ":calendar {\n"
                    ":timezone \"UTC\"\n"
                    "}\n"
                    ":items [\n"
                    "{\n"
                    ":id build\n"
                    ":after [\n"
                    "prepare\n"
                    "review\n"
                    "]\n"
                    ":description `\n"
                    " literal\n"
                    "    deeper\n"
                    "`\n"
                    "}\n"
                    "   \n"
                    "// next item\n"
                    "]\n"
                    "}\n"))
    (indent-region (point-min) (point-max))
    (let ((once (buffer-string))
          (expected (concat "{\n"
                            "  :calendar {\n"
                            "    :timezone \"UTC\"\n"
                            "  }\n"
                            "  :items [\n"
                            "    {\n"
                            "      :id build\n"
                            "      :after [\n"
                            "        prepare\n"
                            "        review\n"
                            "      ]\n"
                            "      :description `\n"
                            " literal\n"
                            "    deeper\n"
                            "      `\n"
                            "    }\n"
                            "   \n"
                            "    // next item\n"
                            "  ]\n"
                            "}\n")))
      (should (equal once expected))
      (should-not (string-match-p "\t" once))
      (indent-region (point-min) (point-max))
      (should (equal (buffer-string) once)))))

(ert-deftest plan-ts-indent-preserves-multiline ()
  "Interior lines of a backtick multiline string keep their literal indent.
Structural reindent must never rewrite string bytes, so a deeply-indented line
inside the backticks is left untouched."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{:description `\n      literal text\n`}")
    (goto-char (point-min))
    (forward-line 1)                    ; the "literal text" line
    (indent-for-tab-command)
    (back-to-indentation)
    (should (= (current-column) 6))))

(ert-deftest plan-ts-indent-aligns-multiline-ending-delimiter ()
  "Multiline content is literal, but its ending backtick aligns with the field."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{\n:description `\n   literal text\n          `\n}")
    (goto-char (point-min))
    (forward-line 2)
    (indent-for-tab-command)
    (should (= (current-indentation) 3))
    (forward-line 1)
    (indent-for-tab-command)
    (should (= (current-indentation) 2))))

(ert-deftest plan-ts-indent-recovers-conservatively ()
  "Incomplete containers use recognizable ancestors and otherwise root depth."
  (with-temp-buffer
    (let ((buffer-file-name "t.plan"))
      (plan-ts-mode))
    (insert "{\n:items [\n{\n:id build\n}\n]\n")
    (should (condition-case nil
                (progn
                  (indent-region (point-min) (point-max))
                  t)
              (error nil)))
    (should (equal (buffer-string)
                   "{\n  :items [\n    {\n      :id build\n    }\n  ]\n"))
    (should (= 0 (plan-ts-mode--structural-offset nil nil (point-min))))))

(ert-deftest plan-ts-mode-disables-tabs-buffer-locally ()
  "Plan structural indentation writes spaces even when tabs are global."
  (let ((indent-tabs-mode t))
    (with-temp-buffer
      (let ((buffer-file-name "t.plan"))
        (plan-ts-mode))
      (should-not indent-tabs-mode)
      (insert "{\n:id demo\n}")
      (goto-char (point-min))
      (forward-line 1)
      (indent-for-tab-command)
      (beginning-of-line)
      (should (looking-at "  :id"))
      (should-not (string-match-p "\t" (buffer-string))))))

(ert-deftest plan-ts-degrade-without-grammar ()
  "Without the grammar the mode still enters, errs not, and creates no parser."
  (let ((treesit-extra-load-path nil)
        (inhibit-message t))
    ;; force the not-ready path even if a system grammar exists
    (cl-letf (((symbol-function 'plan-ts-mode--grammar-ready-p)
               (lambda () nil)))
      (with-temp-buffer
        (let ((buffer-file-name "t.plan"))
          (should (progn (plan-ts-mode) t)))
        (should (derived-mode-p 'plan-ts-mode))
        (should-not (treesit-parser-list nil 'plan))
        (should (equal comment-start "// "))))))

(ert-deftest plan-ts-missing-grammar-hint-uses-public-installation-entry ()
  "The missing-grammar hint points to the public repository instructions."
  (let ((hint (plan-ts-mode--install-hint)))
    (should
     (string-match-p
      (regexp-quote
       "https://github.com/planq-cli/plan-ts-mode#install-the-tree-sitter-grammar")
      hint))
    (should-not (string-match-p "grammar/tree-sitter-plan/scripts" hint))))

(ert-deftest plan-ts-mode-does-not-require-lsp-bridge ()
  "The mode does not require lsp-bridge: highlighting remains standalone."
  ;; lsp-bridge is not loaded in this batch run; opening a `.plan' file must work.
  (should-not (featurep 'lsp-bridge))
  (plan-ts-tests--with-fixture "valid.plan"
    (should (derived-mode-p 'plan-ts-mode))
    (should (treesit-parser-list nil 'plan))
    (should-not (featurep 'lsp-bridge))))

(ert-deftest plan-ts-lsp-bridge-allows-completion-after-blank-value ()
  "Plan buffers bypass only lsp-bridge's generic blank-prefix suppression."
  (let ((predicate 'lsp-bridge--not-only-blank-before-cursor)
        (global '(keep-before
                  lsp-bridge--not-only-blank-before-cursor
                  keep-after)))
    (set 'lsp-bridge-completion-popup-predicates global)
    (unwind-protect
        (with-temp-buffer
          (let ((buffer-file-name "t.plan"))
            (plan-ts-mode))
          (plan-ts-mode--configure-lsp-bridge-completion)
          (should (local-variable-p
                   'lsp-bridge-completion-popup-predicates))
          (should-not
           (memq predicate lsp-bridge-completion-popup-predicates))
          (should (equal lsp-bridge-completion-popup-predicates
                         '(keep-before keep-after)))
          (should (equal (default-value
                           'lsp-bridge-completion-popup-predicates)
                         global)))
      (makunbound 'lsp-bridge-completion-popup-predicates))))

(ert-deftest plan-ts-lsp-registration-is-guarded ()
  "The documented lsp-bridge registration snippet is inert when lsp-bridge is
absent: `with-eval-after-load' defers it, so evaluating it neither errors nor
defines lsp-bridge variables."
  (should-not (featurep 'lsp-bridge))
  ;; mirrors emacs/lsp-bridge/README.md registration snippet
  (should
   (progn
     (with-eval-after-load 'lsp-bridge
       (add-to-list 'lsp-bridge-default-mode-hooks 'plan-ts-mode-hook)
       (add-to-list 'lsp-bridge-single-lang-server-mode-list
                    '(plan-ts-mode . "plan")))
     t))
  ;; deferred: nothing ran, so the variable stays unbound
  (should-not (boundp 'lsp-bridge-single-lang-server-mode-list)))

(ert-deftest plan-ts-langserver-json-is-valid ()
  "plan.json declares command [\"planq\" \"lsp\"] and project-aware mode."
  (let* ((json (expand-file-name "lsp-bridge/plan.json"
                                 plan-ts-tests--emacs-dir))
         (obj (with-temp-buffer
                (insert-file-contents json)
                (json-parse-buffer :object-type 'alist))))
    (should (equal (append (cdr (assq 'command obj)) nil) '("planq" "lsp")))
    (should (eq :false (cdr (assq 'support-single-file obj))))
    (should (equal (cdr (assq 'languageId obj)) "plan"))))

(provide 'plan-ts-mode-tests)

;;; plan-ts-mode-tests.el ends here

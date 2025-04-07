;;; common-lisp-ts-mode.el --- Tree Sitter support for Common Lisp -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.

;; Author: Gabriel Frigo <gabriel.frigo4@gmail.com>
;; URL: https://github.com/GabrielFrigo4/common-lisp-ts-mode
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.3"))

;;; Commentary:

;; To use this tressit mode you need to download Treesit Grammar for Common Lisp
;; from Emacs using this command `treesit-install-language-grammar`.

;; Treesit Gramar for Common Lisp
;; https://github.com/tree-sitter-grammars/tree-sitter-commonlisp

;;; Code:

;; Import *treesit*
(require 'treesit)

;; Def *common-lisp-ts-mode--builtins*
(defvar common-lisp-ts-mode--builtins
  '("&body" "&environment" "&key" "&optional" "&rest" "&whole"
    "assert" "block" "case" "catch" "cond" "ctypecase" "declaim" "declare"
    "defgeneric" "define-compiler-macro" "define-condition" "define-method-combination"
    "define-modify-macro" "define-setf-expander" "define-symbol-macro" "defmacro" 
    "defmethod" "defpackage" "defsetf" "defstruct" "deftype" "defun" "defvar" 
    "destructuring-bind" "do" "do*" "do-all-symbols" "do-external-symbols"
    "do-symbols" "dolist" "dotimes" "ecase" "etypecase" "eval-when" "flet" 
    "handler-bind" "handler-case" "if" "ignore-errors" "in-package" "labels"
    "lambda" "loop" "macrolet" "multiple-value-bind" "multiple-value-call"
    "multiple-value-prog1" "named-let" "otherwise" "print-unreadable-object"
    "prog" "prog*" "prog1" "prog2" "progn" "provide" "require" "restart-bind"
    "restart-case" "return" "return-from" "setf" "shiftf" "step" "symbol-macrolet"
    "tagbody" "the" "throw" "trace" "typecase" "untrace" "unwind-protect" "unless"
    "when" "with-accessors" "with-compilation-unit" "with-condition-restarts"
    "with-hash-table-iterator" "with-input-from-string" "with-open-file" "with-open-stream"
    "with-output-to-string" "with-package-iterator" "with-simple-restart" "with-slots"
    "with-standard-io-syntax"))

;; Def *common-lisp-ts-mode--keywords*
(defvar common-lisp-ts-mode--keywords
  '("defun" "defsubst" "defmacro" "defconst" "defvar"
    ;; Special forms
    "if" "while" "catch" "cond" "condition-case" "function"
    "interactive" "lambda" "let" "let*" "prog1" "prog2" "progn"
    "save-restriction" "save-current-buffer" "save-excursion"
    "quote" "setq" "setq-default" "unwind-protect"))

;; Def *common-lisp-ts-mode--operators*
(defvar common-lisp-ts-mode--operators
  '("*" "/" "%" "+" "-" "mod" "incf" "decf"
    "=" "/=" "<" ">" ">=" "<=" "max" "min"
    "and" "or" "not"))

;; Def *common-lisp-ts-mode--fontify-parameters*
(defun common-lisp-ts-mode--fontify-parameters (node override start end &rest _)
  (treesit-fontify-with-override
   (treesit-node-start node)
   (treesit-node-end node)
   (if (string-prefix-p "&" (treesit-node-text node))
       'font-lock-type-face
     'font-lock-variable-name-face)
   override start end))

;; Def *common-lisp-ts-mode--font-lock-settings*
(defvar common-lisp-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'commonlisp
   :feature 'comment
   `((comment) @font-lock-comment-face)

   :language 'commonlisp
   :feature 'string
   `((str_lit) @font-lock-string-face)

   :language 'commonlisp
   :feature 'number
   `((num_lit) @font-lock-number-face)

   :language 'commonlisp
   :feature 'operator
   `(((sym_lit) @font-lock-operator-face
      (:match ,(rx-to-string
                `(seq bol
                      (or ,@common-lisp-ts-mode--operators)
                      eol))
              @font-lock-operator-face)))

   :language 'commonlisp
   :feature 'keyword
   `([,@common-lisp-ts-mode--keywords] @font-lock-keyword-face
     (quoting_lit ["`" "'" "#'"] @font-lock-keyword-face)
     (unquote_splice ",@" @font-lock-keyword-face)
     (unquote "," @font-lock-keyword-face))

   :language 'commonlisp
   :feature 'constant
   `(["t" "nil"] @font-lock-constant-face)

   :language 'commonlisp
   :feature 'definition
   `((special_form
      _ ["defvar" "setq" "setq-local" "setq-default" "let"] (sym_lit) @font-lock-variable-name-face)

     (function_definition
      name: (sym_lit) @font-lock-function-name-face
      parameters: (list_lit _ (sym_lit) @common-lisp-ts-mode--fontify-parameters :*))

     (macro_definition
      name: (sym_lit) @font-lock-keyword-face
      parameters: (list_lit _ (sym_lit) @common-lisp-ts-mode--fontify-parameters :*)))

   :language 'commonlisp
   :feature 'builtin
   `((list_lit _ ((sym_lit) @font-lock-keyword-face
              (:match ,(rx-to-string
                        `(seq bol
                              (or ,@common-lisp-ts-mode--builtins)
                              eol))
                      @font-lock-keyword-face))))

   :language 'commonlisp
   :feature 'property
   `(((sym_lit) @font-lock-builtin-face
      (:match ,(rx bol ":") @font-lock-builtin-face)))

   :language 'commonlisp
   :feature 'preprocessor
   `(((sym_lit) @font-lock-preprocessor-face
      (:match ,(rx bol "@") @font-lock-preprocessor-face))
     (unquote_splice (sym_lit) @font-lock-preprocessor-face)
     (unquote (sym_lit) @font-lock-preprocessor-face))

   :language 'commonlisp
   :feature 'quoted
   `((quoting_lit (sym_lit) @font-lock-constant-face))

   :language 'commonlisp
   :feature 'bracket
   `(["(" ")" "[" "]" "#[" "#("] @font-lock-bracket-face)

   :language 'commonlisp
   :feature 'variable
   `((vector _ ((sym_lit) @font-lock-variable-name-face)))

   :language 'commonlisp
   :feature 'callable
   `((list_lit _ ((sym_lit) @font-lock-function-call-face)))

   :language 'commonlisp
   :feature 'argument
   `(((sym_lit) @font-lock-variable-name-face))))

;; Def *common-lisp-ts-mode-feature-list*
(defvar common-lisp-ts-mode-feature-list
  `((comment)
    (string keyword definition)
    (builtin constant property preprocessor)
    (bracket number operator quoted variable callable argument)))

;; Define Derived Mode *common-lisp-ts-mode*
(define-derived-mode common-lisp-ts-mode common-lisp-mode "Common Lisp"
  "Major mode for editing Common Lisp code using tree-sitter.

Commands:
\\<common-lisp-ts-mode-map>"
  (when (treesit-ready-p 'commonlisp)
    (treesit-parser-create 'commonlisp)

    (setq-local treesit-font-lock-settings
                common-lisp-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list
                common-lisp-ts-mode-feature-list)

    (treesit-major-mode-setup)))

;; Provide *common-lisp-ts-mode*
(provide 'common-lisp-ts-mode)

;;; common-lisp-ts-mode.el
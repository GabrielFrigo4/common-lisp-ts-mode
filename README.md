# common-lisp-ts-mode
Treesit major mode for editing Common Lisp programs

# Get Treesit Grammar
To use this tressit mode you need to download [Treesit Grammar for Common Lisp][treesit-gramar-commonlisp] from Emacs using this command `treesit-install-language-grammar`

# Installing with Quelpa
If you prefer to use a package manager, you can use [quelpa-use-package].

```elisp
;; Install Treesit for Common Lisp
(use-package common-lisp-ts-mode
  :quelpa (common-lisp-ts-mode :fetcher github :repo "GabrielFrigo4/common-lisp-ts-mode"))
```

[treesit-gramar-commonlisp]: https://github.com/tree-sitter-grammars/tree-sitter-commonlisp
[quelpa-use-package]: https://github.com/quelpa/quelpa-use-package
(ql:quickload 'quickutil)

(qtlc:save-utils-as
  "quickutils.lisp"
  :utilities '(
               :with-gensyms
               :once-only
               :map-permutations
               ; :compose
               :curry
               :rcurry
               :symb
               ; :n-grams
               ; :define-constant
               ; :riffle
               ; :tree-collect
               ; :switch
               ; :while
               ; :ensure-boolean
               ; :iota
               ; :zip
               )
  :package "VEX.QUICKUTILS")

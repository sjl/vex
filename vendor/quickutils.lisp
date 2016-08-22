;;;; This file was automatically generated by Quickutil.
;;;; See http://quickutil.org for details.

;;;; To regenerate:
;;;; (qtlc:save-utils-as "quickutils.lisp" :utilities '(:WITH-GENSYMS :ONCE-ONLY :MAP-PERMUTATIONS :CURRY :RCURRY :SYMB) :ensure-package T :package "VEX.QUICKUTILS")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package "VEX.QUICKUTILS")
    (defpackage "VEX.QUICKUTILS"
      (:documentation "Package that contains Quickutil utility functions.")
      (:use #:cl))))

(in-package "VEX.QUICKUTILS")

(when (boundp '*utilities*)
  (setf *utilities* (union *utilities* '(:STRING-DESIGNATOR :WITH-GENSYMS
                                         :MAKE-GENSYM-LIST :ONCE-ONLY
                                         :ENSURE-FUNCTION :MAP-COMBINATIONS
                                         :MAP-PERMUTATIONS :CURRY :RCURRY
                                         :MKSTR :SYMB))))

  (deftype string-designator ()
    "A string designator type. A string designator is either a string, a symbol,
or a character."
    `(or symbol string character))
  

  (defmacro with-gensyms (names &body forms)
    "Binds each variable named by a symbol in `names` to a unique symbol around
`forms`. Each of `names` must either be either a symbol, or of the form:

    (symbol string-designator)

Bare symbols appearing in `names` are equivalent to:

    (symbol symbol)

The string-designator is used as the argument to `gensym` when constructing the
unique symbol the named variable will be bound to."
    `(let ,(mapcar (lambda (name)
                     (multiple-value-bind (symbol string)
                         (etypecase name
                           (symbol
                            (values name (symbol-name name)))
                           ((cons symbol (cons string-designator null))
                            (values (first name) (string (second name)))))
                       `(,symbol (gensym ,string))))
            names)
       ,@forms))

  (defmacro with-unique-names (names &body forms)
    "Binds each variable named by a symbol in `names` to a unique symbol around
`forms`. Each of `names` must either be either a symbol, or of the form:

    (symbol string-designator)

Bare symbols appearing in `names` are equivalent to:

    (symbol symbol)

The string-designator is used as the argument to `gensym` when constructing the
unique symbol the named variable will be bound to."
    `(with-gensyms ,names ,@forms))
  
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun make-gensym-list (length &optional (x "G"))
    "Returns a list of `length` gensyms, each generated as if with a call to `make-gensym`,
using the second (optional, defaulting to `\"G\"`) argument."
    (let ((g (if (typep x '(integer 0)) x (string x))))
      (loop repeat length
            collect (gensym g))))
  )                                        ; eval-when

  (defmacro once-only (specs &body forms)
    "Evaluates `forms` with symbols specified in `specs` rebound to temporary
variables, ensuring that each initform is evaluated only once.

Each of `specs` must either be a symbol naming the variable to be rebound, or of
the form:

    (symbol initform)

Bare symbols in `specs` are equivalent to

    (symbol symbol)

Example:

    (defmacro cons1 (x) (once-only (x) `(cons ,x ,x)))
      (let ((y 0)) (cons1 (incf y))) => (1 . 1)"
    (let ((gensyms (make-gensym-list (length specs) "ONCE-ONLY"))
          (names-and-forms (mapcar (lambda (spec)
                                     (etypecase spec
                                       (list
                                        (destructuring-bind (name form) spec
                                          (cons name form)))
                                       (symbol
                                        (cons spec spec))))
                                   specs)))
      ;; bind in user-macro
      `(let ,(mapcar (lambda (g n) (list g `(gensym ,(string (car n)))))
              gensyms names-and-forms)
         ;; bind in final expansion
         `(let (,,@(mapcar (lambda (g n)
                             ``(,,g ,,(cdr n)))
                           gensyms names-and-forms))
            ;; bind in user-macro
            ,(let ,(mapcar (lambda (n g) (list (car n) g))
                    names-and-forms gensyms)
               ,@forms)))))
  
(eval-when (:compile-toplevel :load-toplevel :execute)
  ;;; To propagate return type and allow the compiler to eliminate the IF when
  ;;; it is known if the argument is function or not.
  (declaim (inline ensure-function))

  (declaim (ftype (function (t) (values function &optional))
                  ensure-function))
  (defun ensure-function (function-designator)
    "Returns the function designated by `function-designator`:
if `function-designator` is a function, it is returned, otherwise
it must be a function name and its `fdefinition` is returned."
    (if (functionp function-designator)
        function-designator
        (fdefinition function-designator)))
  )                                        ; eval-when

  (defun map-combinations (function sequence &key (start 0) end length (copy t))
    "Calls `function` with each combination of `length` constructable from the
elements of the subsequence of `sequence` delimited by `start` and `end`. `start`
defaults to `0`, `end` to length of `sequence`, and `length` to the length of the
delimited subsequence. (So unless `length` is specified there is only a single
combination, which has the same elements as the delimited subsequence.) If
`copy` is true (the default) each combination is freshly allocated. If `copy` is
false all combinations are `eq` to each other, in which case consequences are
specified if a combination is modified by `function`."
    (let* ((end (or end (length sequence)))
           (size (- end start))
           (length (or length size))
           (combination (subseq sequence 0 length))
           (function (ensure-function function)))
      (if (= length size)
          (funcall function combination)
          (flet ((call ()
                   (funcall function (if copy
                                         (copy-seq combination)
                                         combination))))
            (etypecase sequence
              ;; When dealing with lists we prefer walking back and
              ;; forth instead of using indexes.
              (list
               (labels ((combine-list (c-tail o-tail)
                          (if (not c-tail)
                              (call)
                              (do ((tail o-tail (cdr tail)))
                                  ((not tail))
                                (setf (car c-tail) (car tail))
                                (combine-list (cdr c-tail) (cdr tail))))))
                 (combine-list combination (nthcdr start sequence))))
              (vector
               (labels ((combine (count start)
                          (if (zerop count)
                              (call)
                              (loop for i from start below end
                                    do (let ((j (- count 1)))
                                         (setf (aref combination j) (aref sequence i))
                                         (combine j (+ i 1)))))))
                 (combine length start)))
              (sequence
               (labels ((combine (count start)
                          (if (zerop count)
                              (call)
                              (loop for i from start below end
                                    do (let ((j (- count 1)))
                                         (setf (elt combination j) (elt sequence i))
                                         (combine j (+ i 1)))))))
                 (combine length start)))))))
    sequence)
  

  (defun map-permutations (function sequence &key (start 0) end length (copy t))
    "Calls function with each permutation of `length` constructable
from the subsequence of `sequence` delimited by `start` and `end`. `start`
defaults to `0`, `end` to length of the sequence, and `length` to the
length of the delimited subsequence."
    (let* ((end (or end (length sequence)))
           (size (- end start))
           (length (or length size)))
      (labels ((permute (seq n)
                 (let ((n-1 (- n 1)))
                   (if (zerop n-1)
                       (funcall function (if copy
                                             (copy-seq seq)
                                             seq))
                       (loop for i from 0 upto n-1
                             do (permute seq n-1)
                                (if (evenp n-1)
                                    (rotatef (elt seq 0) (elt seq n-1))
                                    (rotatef (elt seq i) (elt seq n-1)))))))
               (permute-sequence (seq)
                 (permute seq length)))
        (if (= length size)
            ;; Things are simple if we need to just permute the
            ;; full START-END range.
            (permute-sequence (subseq sequence start end))
            ;; Otherwise we need to generate all the combinations
            ;; of LENGTH in the START-END range, and then permute
            ;; a copy of the result: can't permute the combination
            ;; directly, as they share structure with each other.
            (let ((permutation (subseq sequence 0 length)))
              (flet ((permute-combination (combination)
                       (permute-sequence (replace permutation combination))))
                (declare (dynamic-extent #'permute-combination))
                (map-combinations #'permute-combination sequence
                                  :start start
                                  :end end
                                  :length length
                                  :copy nil)))))))
  

  (defun curry (function &rest arguments)
    "Returns a function that applies `arguments` and the arguments
it is called with to `function`."
    (declare (optimize (speed 3) (safety 1) (debug 1)))
    (let ((fn (ensure-function function)))
      (lambda (&rest more)
        (declare (dynamic-extent more))
        ;; Using M-V-C we don't need to append the arguments.
        (multiple-value-call fn (values-list arguments) (values-list more)))))

  (define-compiler-macro curry (function &rest arguments)
    (let ((curries (make-gensym-list (length arguments) "CURRY"))
          (fun (gensym "FUN")))
      `(let ((,fun (ensure-function ,function))
             ,@(mapcar #'list curries arguments))
         (declare (optimize (speed 3) (safety 1) (debug 1)))
         (lambda (&rest more)
           (apply ,fun ,@curries more)))))
  

  (defun rcurry (function &rest arguments)
    "Returns a function that applies the arguments it is called
with and `arguments` to `function`."
    (declare (optimize (speed 3) (safety 1) (debug 1)))
    (let ((fn (ensure-function function)))
      (lambda (&rest more)
        (declare (dynamic-extent more))
        (multiple-value-call fn (values-list more) (values-list arguments)))))
  

  (defun mkstr (&rest args)
    "Receives any number of objects (string, symbol, keyword, char, number), extracts all printed representations, and concatenates them all into one string.

Extracted from _On Lisp_, chapter 4."
    (with-output-to-string (s)
      (dolist (a args) (princ a s))))
  

  (defun symb (&rest args)
    "Receives any number of objects, concatenates all into one string with `#'mkstr` and converts them to symbol.

Extracted from _On Lisp_, chapter 4.

See also: `symbolicate`"
    (values (intern (apply #'mkstr args))))
  
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(with-gensyms with-unique-names once-only map-permutations curry
            rcurry symb)))

;;;; END OF quickutils.lisp ;;;;
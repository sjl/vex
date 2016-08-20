(in-package #:vex-test)

;;;; Boilerplate
(defparameter *test-count* 50)

(defmacro define-test (name &body body)
  `(test ,name
    (let ((*package* ,*package*))
      ,@body)))

(defun run-tests ()
  (1am:run))

(defmacro check (bindings &rest body)
  `(loop
    :repeat *test-count*
    :do (let ,(loop :for (var generator) :in bindings
                    :collect `(,var (funcall ,generator)))
          ,@body)))


;;;; Generators
(defun random-range (min max)
  "Return a random number between [`min`, `max`)."
  (+ min (random (- max min))))

(defun fixnum! ()
  (random-range most-negative-fixnum (1+ most-positive-fixnum)))

(defun integer! ()
  (random-range (* 100 most-negative-fixnum)
                (* 100 most-positive-fixnum)))

(defun single-float! ()
  (coerce (random-range (coerce most-negative-single-float 'double-float)
                        (coerce most-positive-single-float 'double-float))
          'single-float))

(defun small-single-float! ()
  (/ (single-float!) 10.0))

(defun small-double-float! ()
  (random-range (/ (coerce most-negative-double-float 'double-float) 10.0d0)
                (/ (coerce most-positive-double-float 'double-float) 10.0d0)))


;;;; Tests
(defun is-commutative (test op a b)
  (is (funcall test
               (funcall op a b)
               (funcall op b a))))

(defun is-associative (test op a b c)
  (is (funcall test
               (funcall op (funcall op a b) c)
               (funcall op a (funcall op b c)))))

(define-test vec2-integer-addition
  (flet ((check-add (vec veql vadd g1 g2 g3 g4)
           (check ((ax g1)
                   (ay g2)
                   (bx g3)
                   (by g4))
             (let* ((v1 (funcall vec ax ay))
                    (v2 (funcall vec bx by))
                    (v3 (funcall vec ax by)))
               (is-commutative veql vadd v1 v2)
               (is-associative veql vadd v1 v2 v3)))))
    (check-add
      #'vec2 #'vec2-eql #'vec2-add
      #'fixnum!
      #'fixnum!
      #'fixnum!
      #'fixnum!)
    (check-add
      #'vec2i #'vec2i-eql #'vec2i-add
      #'fixnum!
      #'fixnum!
      #'fixnum!
      #'fixnum!)
    (check-add
      #'vec2 #'vec2-eql #'vec2-add
      #'integer!
      #'integer!
      #'integer!
      #'integer!)))

(define-test vec2-float-addition
  (flet ((check-add (vec veql vadd g1 g2 g3 g4)
           (check ((ax g1)
                   (ay g2)
                   (bx g3)
                   (by g4))
             (let* ((v1 (funcall vec ax ay))
                    (v2 (funcall vec bx by)))
               (is-commutative veql vadd v1 v2)))))
    ;; vec2 with singles
    (check-add
      #'vec2 #'vec2-eql #'vec2-add
      #'small-single-float!
      #'small-single-float!
      #'small-single-float!
      #'small-single-float!)
    ;; vec2f with singles
    (check-add
      #'vec2f #'vec2f-eql #'vec2f-add
      #'small-single-float!
      #'small-single-float!
      #'small-single-float!
      #'small-single-float!)
    ;; vec2 with doubles
    (check-add
      #'vec2 #'vec2-eql #'vec2-add
      #'small-double-float!
      #'small-double-float!
      #'small-double-float!
      #'small-double-float!)
    ;; vec2d with doubles
    (check-add
      #'vec2d #'vec2d-eql #'vec2d-add
      #'small-double-float!
      #'small-double-float!
      #'small-double-float!
      #'small-double-float!)
    ;; vec2 with both
    (check-add
      #'vec2 #'vec2-eql #'vec2-add
      #'small-single-float!
      #'small-single-float!
      #'small-double-float!
      #'small-double-float!)))

(in-package #:vex)


;;;; Utils
(declaim (inline square))


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun symbolize (&rest args)
    (intern (format nil "~{~A~}" args))))


(defun square (x)
  (* x x))

(defmacro defuns (names &rest rest)
  `(progn
     ,@(loop :for name :in names :collect `(defun ,name ,@rest))))


;;;; Structs
(defmacro defvec (name slots arglist type default)
  `(progn
    (declaim (inline ,name))
    (defstruct (,name (:constructor ,name ,arglist))
      ,(format nil "A ~R-dimensional vector of `~A`s."
               (length slots)
               type)
      ,@(loop :for slot :in slots :collect `(,slot ,default :type ,type)))
    (declaim (notinline ,name))))

(defmacro defvec2 (name type default)
  `(defvec ,name (x y) (&optional (x ,default) (y x)) ,type ,default))

(defmacro defvec3 (name type default)
  `(defvec ,name (x y z) (&optional (x ,default) (y x) (z y)) ,type ,default))

(defmacro defvec4 (name type default)
  `(defvec ,name (x y z w) (&optional (x ,default) (y x) (z y) (w z)) ,type ,default))


(defvec2 vec2 real 0)
(defvec2 vec2f single-float 0f0)
(defvec2 vec2d double-float 0d0)
(defvec2 vec2i fixnum 0)

(defvec3 vec3 real 0)
(defvec3 vec3f single-float 0f0)
(defvec3 vec3d double-float 0d0)
(defvec3 vec3i fixnum 0)

(defvec4 vec4 real 0)
(defvec4 vec4f single-float 0f0)
(defvec4 vec4d double-float 0d0)
(defvec4 vec4i fixnum 0)


;;;; Operations
(defmacro with-fns (vec-type element-type &body body)
  `(progn
    (declaim (inline ,vec-type))
    (macrolet
        ((vec (&rest args) `(,',vec-type ,@args))
         (vec-x (v) `(,(symbolize ',vec-type '-x) ,v))
         (vec-y (v) `(,(symbolize ',vec-type '-y) ,v))
         (vec-z (v) `(,(symbolize ',vec-type '-z) ,v))
         (vec-w (v) `(,(symbolize ',vec-type '-w) ,v))
         ,(if (eq element-type 'fixnum)
            `(wrap (x) `(logand most-positive-fixnum ,x))
            `(wrap (x) x))
         ,(if (eq element-type 'fixnum)
            `(// (x y) `(floor ,x ,y))
            `(// (x y) `(/ ,x ,y))))
      ,@body)
    (declaim (notinline ,vec-type))))

(defmacro defvec2ops (vec-type element-type)
  (let ((add (symbolize vec-type '-add))
        (add* (symbolize vec-type '-add*))
        (add! (symbolize vec-type '-add!))
        (add*! (symbolize vec-type '-add*!))
        (sub (symbolize vec-type '-sub))
        (sub* (symbolize vec-type '-sub*))
        (sub! (symbolize vec-type '-sub!))
        (sub*! (symbolize vec-type '-sub*!))
        (mul (symbolize vec-type '-mul))
        (mul! (symbolize vec-type '-mul!))
        (div (symbolize vec-type '-div))
        (div! (symbolize vec-type '-div!))
        (eql (symbolize vec-type '-eql))
        (magdir (symbolize vec-type '-magdir))
        (magnitude (symbolize vec-type '-magnitude))
        (length (symbolize vec-type '-length))
        (angle (symbolize vec-type '-angle))
        (direction (symbolize vec-type '-direction))
        (set! (symbolize vec-type '-set!)))
    `(progn
      (declaim
        (ftype (function (,element-type ,element-type)
                         (values ,vec-type &optional))
               ,magdir)

        (ftype (function (,vec-type ,vec-type &optional (or null ,element-type))
                         (values boolean &optional))
               ,eql)

        (ftype (function (,vec-type ,vec-type)
                         (values ,vec-type &optional))
               ,add ,sub ,add! ,sub!)

        (ftype (function (,vec-type ,element-type ,element-type)
                         (values ,vec-type &optional))
               ,add* ,add*! ,sub* ,sub*! ,set!)

        (ftype (function (,vec-type ,element-type)
                         (values ,vec-type &optional))
               ,mul ,div ,mul! ,div!)

        (ftype (function (,vec-type)
                         ,(if (eq 'fixnum element-type)
                            `(values real &optional)
                            `(values ,element-type &optional)))
               ,magnitude ,length ,angle ,direction))

      (with-fns
        ,vec-type ,element-type

        (defun ,set! (v x y)
          "Destructively set the components of `v` to `x` and `y`, returning `v`."
          (setf (vec-x v) x
                (vec-y v) y)
          v)

        (defun ,magdir (magnitude direction)
          "Create a fresh vector with the given `magnitude` and `direction`."
          ;; todo figure this out for integer vectors
          (vec
            (* magnitude (cos direction))
            (* magnitude (sin direction))))

        (defun ,eql (v1 v2 &optional epsilon)
          "Return whether `v1` and `v2` are componentwise `=`.

          If `epsilon` is given, this instead checks that each pair of
          components are within `epsilon` of each other.

          "
          (if epsilon
            (and (<= (abs (- (vec-x v1) (vec-x v2))) epsilon)
                 (<= (abs (- (vec-y v1) (vec-y v2))) epsilon))
            (and (= (vec-x v1) (vec-x v2))
                 (= (vec-y v1) (vec-y v2)))))

        (defun ,add (v1 v2)
          "Add `v1` and `v2` componentwise, returning a new vector."
          (vec (wrap (+ (vec-x v1) (vec-x v2)))
               (wrap (+ (vec-y v1) (vec-y v2)))))

        (defun ,add* (v x y)
          "Add `x` and `y` to the components of `v`, returning a new vector."
          (vec (wrap (+ (vec-x v) x))
               (wrap (+ (vec-y v) y))))

        (defun ,add! (v1 v2)
          "Destructively update `v1` by adding `v2` componentwise, returning `v1`."
          (setf (vec-x v1) (wrap (+ (vec-x v1) (vec-x v2)))
                (vec-y v1) (wrap (+ (vec-y v1) (vec-y v2))))
          v1)

        (defun ,add*! (v x y)
          "Destructively update `v` by adding `x` and `y`, returning `v`."
          (setf (vec-x v) (wrap (+ (vec-x v) x))
                (vec-y v) (wrap (+ (vec-y v) y)))
          v)

        (defun ,sub (v1 v2)
          "Subtract `v1` and `v2` componentwise, returning a new vector."
          (vec (wrap (- (vec-x v1) (vec-x v2)))
               (wrap (- (vec-y v1) (vec-y v2)))))

        (defun ,sub* (v x y)
          "Subtract `x` and `y` from the components of `v`, returning a new vector."
          (vec (wrap (- (vec-x v) x))
               (wrap (- (vec-y v) y))))

        (defun ,sub! (v1 v2)
          "Destructively update `v1` by subtracting `v2` componentwise, returning `v1`."
          (setf (vec-x v1) (wrap (- (vec-x v1) (vec-x v2)))
                (vec-y v1) (wrap (- (vec-y v1) (vec-y v2))))
          v1)

        (defun ,sub*! (v x y)
          "Destructively update `v` by subtracting `x` and `y`, returning `v`."
          (setf (vec-x v) (wrap (- (vec-x v) x))
                (vec-y v) (wrap (- (vec-y v) y)))
          v)

        (defun ,mul (v scalar)
          "Multiply the components of `v` by `scalar`, returning a new vector."
          (vec (wrap (* (vec-x v) scalar))
               (wrap (* (vec-y v) scalar))))

        (defun ,mul! (v scalar)
          "Destructively multiply the components of `v` by `scalar`, returning `v`."
          (setf (vec-x v) (wrap (* (vec-x v) scalar))
                (vec-y v) (wrap (* (vec-y v) scalar)))
          v)

        (defun ,div (v scalar)
          "Divide the components of `v` by `scalar`, returning a new vector."
          (vec (wrap (// (vec-x v) scalar))
               (wrap (// (vec-y v) scalar))))

        (defun ,div! (v scalar)
          "Destructively divide the components of `v` by `scalar`, returning `v`."
          (setf (vec-x v) (wrap (// (vec-x v) scalar))
                (vec-y v) (wrap (// (vec-y v) scalar)))
          v)

        (defuns (,magnitude ,length) (v)
          "Return the magnitude of `v`."
          (sqrt (+ (square (vec-x v))
                   (square (vec-y v)))))

        (defuns (,angle ,direction) (v)
          "Return the angle of `v`."
          (atan (vec-y v) (vec-x v)))))))


(defvec2ops vec2 real)
(defvec2ops vec2f single-float)
(defvec2ops vec2d double-float)
(defvec2ops vec2i fixnum)

; (declaim (optimize (speed 3) (safety 1) (debug 0)))
; vec2i-eql
; vec2f-add
; vec2f-add*
; vec2f-add!
; vec2f-add*!
; vec2f-set!
; vec2f-sub*!
; vec2f-add!
; vec2f-sub!
; vec2f-mul!
; vec2f-div
; vec2f-mul
; vec2f
; vec2f-div!

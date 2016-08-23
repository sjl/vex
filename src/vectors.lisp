(in-package #:vex)


;;;; Utils --------------------------------------------------------------------
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun permutations (seq)
    (let (result)
      ; jesus christ alexandria
      (map-permutations (lambda (p) (push p result)) seq)
      result))

  (defun english-list (l)
    ;; thanks seibel
    (format nil "~{~#[~;~a~;~a and ~a~:;~@{~a~#[~;, and ~:;, ~]~}~]~}" l)))


(declaim (inline square))

(defun square (x)
  (* x x))

(defmacro defuns (names &rest rest)
  `(progn
     ,@(loop :for name :in names :collect `(defun ,name ,@rest))))


;;;; Structs ------------------------------------------------------------------
(defmacro defvec (name slots arglist type default)
  `(progn
    (declaim (inline ,name))
    (defstruct (,name (:constructor ,name ,arglist))
      ,(format nil "A ~R-dimensional vector of `~A`s."
               (length slots)
               type)
      ,@(loop :for slot :in slots :collect `(,slot ,default :type ,type)))))

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


;;;; Operations ---------------------------------------------------------------
(defmacro define-swizzle (vec-type &rest args)
  (labels
      ((accessor (symbol)
         (symb vec-type '- symbol))
       (docstring-args (args)
         (english-list
           (mapcar (curry #'format nil "`~(~A~)`") args)))
       (docstring-fresh (args)
         (format nil
                 "Swizzle `v`, returning a new `~(~A~)` of its ~A components."
                 vec-type (docstring-args args)))
       (docstring-inplace (args)
         (format nil
                 "Swizzle `v` in-place and return it, setting its components to ~A."
                 (docstring-args args))))
    `(progn
      ,@(loop
          :for perm :in (permutations args)
          :for name = (apply #'symb vec-type '- perm)
          :for name! = (symb name '!)
          :collect
          `(declaim (ftype (function (,vec-type) (values ,vec-type &optional))
                           ,name ,name!))
          :collect
          `(defun ,name (v)
            ,(docstring-fresh perm)
            (,vec-type
             ,@(loop :for accessor :in (mapcar #'accessor perm)
                     :collect `(,accessor v))))
          :collect
          `(defun ,name! (v)
            ,(docstring-inplace perm)
            (psetf ,@(loop
                       :for arg-accessor :in (mapcar #'accessor args)
                       :for perm-accessor :in (mapcar #'accessor perm)
                       :collect `(,arg-accessor v)
                       :collect `(,perm-accessor v)))
            v)))))


(defmacro with-fns (vec-type element-type &body body)
  `(macrolet
    ((vec (&rest args) `(,',vec-type ,@args))
     (vec-x (v) `(,(symb ',vec-type '-x) ,v))
     (vec-y (v) `(,(symb ',vec-type '-y) ,v))
     (vec-z (v) `(,(symb ',vec-type '-z) ,v))
     (vec-w (v) `(,(symb ',vec-type '-w) ,v))
     ,(if (eq element-type 'fixnum)
        `(wrap (x) `(logand most-positive-fixnum ,x))
        `(wrap (x) x))
     ,(if (eq element-type 'fixnum)
        `(// (x y) `(floor ,x ,y))
        `(// (x y) `(/ ,x ,y))))
    ,@body))

(defmacro defvec2ops (vec-type element-type)
  (let ((add (symb vec-type '-add))
        (add* (symb vec-type '-add*))
        (add! (symb vec-type '-add!))
        (add*! (symb vec-type '-add*!))
        (sub (symb vec-type '-sub))
        (sub* (symb vec-type '-sub*))
        (sub! (symb vec-type '-sub!))
        (sub*! (symb vec-type '-sub*!))
        (mul (symb vec-type '-mul))
        (mul! (symb vec-type '-mul!))
        (div (symb vec-type '-div))
        (div! (symb vec-type '-div!))
        (eql (symb vec-type '-eql))
        (zero (symb vec-type '-zero))
        (unit-x (symb vec-type '-unit-x))
        (unit-y (symb vec-type '-unit-y))
        (magdir (symb vec-type '-magdir))
        (magnitude (symb vec-type '-magnitude))
        (length (symb vec-type '-length))
        (angle (symb vec-type '-angle))
        (direction (symb vec-type '-direction))
        (set! (symb vec-type '-set!)))
    `(progn
      (declaim
        (ftype (function ()
                         (values ,vec-type &optional))
               ,zero ,unit-x ,unit-y)

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

        (defun ,zero ()
          "Return a fresh zero vector."
          (vec (coerce 0 ',element-type)
               (coerce 0 ',element-type)))

        (defun ,unit-x ()
          "Return a unit vector in the X direction."
          (vec (coerce 1 ',element-type)
               (coerce 0 ',element-type)))

        (defun ,unit-y ()
          "Return a unit vector in the Y direction."
          (vec (coerce 0 ',element-type)
               (coerce 1 ',element-type)))

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
          (atan (vec-y v) (vec-x v)))

        (define-swizzle ,vec-type x y)))))


(defvec2ops vec2 real)
(defvec2ops vec2f single-float)
(defvec2ops vec2d double-float)
(defvec2ops vec2i fixnum)


;;;; Scratch ------------------------------------------------------------------
; (declaim (optimize (speed 3) (safety 1) (debug 1)))
; (declaim (optimize (speed 3) (safety 0) (debug 0)))
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
; vec2f-yx
; vec2f-yx!
; vec2f
; vec2f-div!
; vec2f-unit-y

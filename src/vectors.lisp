(in-package #:vex)

(declaim (optimize (speed 3) (safety 0) (debug 0)))


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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (define-constant +setf-expander-help+
    "Destructively set the components of `v` to particular values.

  The values should be given as a `(values ...)` form.

  If only fewer values than components are given, the remaining values default
  to the last given one.

  If no values are given, both all components are set to zero.

  Examples:

    (defparameter *foo* (vec2f 0.0 0.0))
    ; foo = [0.0, 0.0]

    (setf (vec2f *foo*) (values 1.0 2.0))
    ; foo = [1.0, 2.0]

    (setf (vec2f *foo*) (values 8.0))
    ; foo = [8.0, 8.0]

    (setf (vec2f *foo*) (values))
    ; foo = [0.0, 0.0]

    (defparameter *bar* (vec2f 3.0 9.0))
    ; foo = [0.0, 0.0]
    ; bar = [3.0, 9.0]

    (rotatef (vec2f *foo*) (vec2f *bar*))
    ; foo = [3.0, 9.0]
    ; bar = [0.0, 0.0]

  "
    :test #'equal))


(declaim (inline wrap-bounds))
(defun wrap-bounds (n lower upper)
  (let* ((range (1+ (- upper lower)))
         (n (mod (- n lower) range)))
    (if (minusp n)
      (+ upper 1 n)
      (+ lower n))))


(deftype unsigned-fixnum ()
  '(and (integer 0) fixnum))


;;;; Structs ------------------------------------------------------------------
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun setf-expander-form (name slots default)
    `(define-setf-expander ,name (v)
      #.+setf-expander-help+
      ;; turn back now
      (let ((val-vars (mapcar #'make-gensym ',slots))
            (actual-vars (mapcar #'make-gensym ',slots))
            (accessors ',(mapcar (lambda (slot)
                                   (symb name '- slot))
                                 slots)))
        (with-gensyms (vec)
          (values `(,vec)
                  `(,v)
                  `(,@val-vars)
                  `(let* ,(loop
                            :for prev-actual = ,default :then actual
                            :for val :in val-vars
                            :for actual :in actual-vars
                            :collect `(,actual (or ,val ,prev-actual)))
                    (setf
                      ,@(loop :for actual :in actual-vars
                              :for accessor :in accessors
                              :collect `(,accessor ,vec)
                              :collect actual))
                    (values ,@actual-vars))
                  `(values
                    ,@(loop :for accessor :in accessors
                            :collect `(,accessor ,vec)))))))))

(defmacro defvec (name slots arglist type default)
  `(progn
    (declaim (inline ,name))
    (defstruct (,name (:constructor ,name ,arglist))
      ,(format nil "A ~R-dimensional vector of `~A`s."
               (length slots)
               type)
      ,@(loop :for slot :in slots :collect `(,slot ,default :type ,type)))
    ,(setf-expander-form name slots default)
    ',name))

(defmacro defvec2 (name type default)
  `(defvec ,name (x y) (&optional (x ,default) (y x)) ,type ,default))

(defmacro defvec3 (name type default)
  `(defvec ,name (x y z) (&optional (x ,default) (y x) (z y)) ,type ,default))

(defmacro defvec4 (name type default)
  `(defvec ,name (x y z w) (&optional (x ,default) (y x) (z y) (w z)) ,type ,default))


(defvec2 vec2 real 0)
(defvec2 vec2f single-float 0f0)
(defvec2 vec2d double-float 0d0)
(defvec2 vec2i integer 0)
(defvec2 vec2s fixnum 0)
(defvec2 vec2u unsigned-fixnum 0)
(defvec2 vec2u8 (unsigned-byte 8) 0)
(defvec2 vec2u16 (unsigned-byte 16) 0)
(defvec2 vec2u32 (unsigned-byte 32) 0)
(defvec2 vec2u64 (unsigned-byte 64) 0)
(defvec2 vec2s8 (signed-byte 8) 0)
(defvec2 vec2s16 (signed-byte 16) 0)
(defvec2 vec2s32 (signed-byte 32) 0)
(defvec2 vec2s64 (signed-byte 64) 0)

(defvec3 vec3 real 0)
(defvec3 vec3f single-float 0f0)
(defvec3 vec3d double-float 0d0)
(defvec3 vec3i fixnum 0)
(defvec3 vec3u8 (unsigned-byte 8) 0)
(defvec3 vec3u16 (unsigned-byte 16) 0)
(defvec3 vec3u32 (unsigned-byte 32) 0)
(defvec3 vec3u64 (unsigned-byte 64) 0)

(defvec4 vec4 real 0)
(defvec4 vec4f single-float 0f0)
(defvec4 vec4d double-float 0d0)
(defvec4 vec4i fixnum 0)
(defvec4 vec4u8 (unsigned-byte 8) 0)
(defvec4 vec4u16 (unsigned-byte 16) 0)
(defvec4 vec4u32 (unsigned-byte 32) 0)
(defvec4 vec4u64 (unsigned-byte 64) 0)


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
  (let ((vec-x (symb vec-type '-x))
        (vec-y (symb vec-type '-y))
        (vec-z (symb vec-type '-z))
        (vec-w (symb vec-type '-w)))
    `(let ((vec-x ',vec-x)
           (vec-y ',vec-y)
           (vec-z ',vec-z)
           (vec-w ',vec-w))
      (declare (ignorable vec-x vec-y vec-z vec-w))
      (macrolet
          ((vec (&rest args) `(,',vec-type ,@args))
           (vec-x (v) `(,',vec-x ,v))
           (vec-y (v) `(,',vec-y ,v))
           (vec-z (v) `(,',vec-z ,v))
           (vec-w (v) `(,',vec-w ,v))
           (wrap (x)
             ,(cond
                ((eq element-type 'integer)
                 `x)
                ((eq element-type 'fixnum)
                 ``(wrap-bounds ,x 0 most-positive-fixnum))
                ((eq element-type 'unsigned-fixnum)
                 ``(wrap-bounds ,x 0 most-positive-fixnum))
                ((subtypep element-type '(unsigned-byte *))
                 ``(wrap-bounds ,x 0 ,,(1- (expt 2 (second element-type)))))
                ((subtypep element-type '(signed-byte *))
                 ``(wrap-bounds ,x
                    ,,(- (expt 2 (1- (second element-type))))
                    ,,(1- (expt 2 (1- (second element-type))))))
                (t `x)))
           (// (x y)
             ,(if (subtypep element-type 'integer)
                ``(floor ,x ,y)
                ``(/ ,x ,y))))
        ,@body))))

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
        (abs (symb vec-type '-abs))
        (abs! (symb vec-type '-abs!)))
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

        (ftype (function (,vec-type)
                         (values ,vec-type &optional))
               ,abs ,abs!)

        (ftype (function (,vec-type ,vec-type)
                         (values ,vec-type &optional))
               ,add ,sub ,add! ,sub!)

        (ftype (function (,vec-type ,element-type &optional ,element-type)
                         (values ,vec-type &optional))
               ,add* ,add*! ,sub* ,sub*!)

        (ftype (function (,vec-type ,element-type)
                         (values ,vec-type &optional))
               ,mul ,div ,mul! ,div!)

        (ftype (function (,vec-type)
                         ,(if (subtypep element-type 'integer)
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
          "Return a fresh unit vector in the X direction."
          (vec (coerce 1 ',element-type)
               (coerce 0 ',element-type)))

        (defun ,unit-y ()
          "Return a fresh unit vector in the Y direction."
          (vec (coerce 0 ',element-type)
               (coerce 1 ',element-type)))

        (define-setf-expander ,vec-type (v)
          "Destructively set the components of `v` to particular values.

  The values should be given as a `(values x y)` form.
  If only one value is given, both `x` and `y` are set to it.
  If no values are given, both `x` and `y` are set to zero.

  Examples:

    (defparameter *foo* (vec2f 0.0 0.0))
    ; foo = [0.0, 0.0]

    (setf (vec2f *foo*) (values 1.0 2.0))
    ; foo = [1.0, 2.0]

    (setf (vec2f *foo*) (values 8.0))
    ; foo = [8.0, 8.0]

    (setf (vec2f *foo*) (values))
    ; foo = [0.0, 0.0]

    (defparameter *bar* (vec2f 3.0 9.0))
    ; foo = [0.0, 0.0]
    ; bar = [3.0, 9.0]

    (rotatef (vec2f *foo*) (vec2f *bar*))
    ; foo = [3.0, 9.0]
    ; bar = [0.0, 0.0]

  "
          (let ((default (coerce 0 ',element-type)))
            (with-gensyms (vec xval yval x y)
              (values `(,vec)
                      `(,v)
                      `(,xval ,yval)
                      `(let* ((,x (or ,xval ,default))
                              (,y (or ,yval ,x)))
                        (setf (,vec-x ,vec) ,x
                              (,vec-y ,vec) ,y)
                        (values ,x ,y))
                      `(values
                        (,vec-x ,vec)
                        (,vec-y ,vec))))))

        ,(unless (subtypep element-type 'integer)
           `(defun ,magdir (magnitude direction)
             "Create a fresh vector with the given `magnitude` and `direction`."
             ;; todo figure this out for integer vectors
             (vec
               (* magnitude (cos direction))
               (* magnitude (sin direction)))))

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

        (defun ,add* (v x &optional (y x))
          "Add `x` and `y` to the components of `v`, returning a new vector."
          (declare (type ,element-type y))
          (vec (wrap (+ (vec-x v) x))
               (wrap (+ (vec-y v) y))))

        (defun ,add! (v1 v2)
          "Destructively update `v1` by adding `v2` componentwise, returning `v1`."
          (setf (,vec-type v1)
                (values (wrap (+ (vec-x v1) (vec-x v2)))
                        (wrap (+ (vec-y v1) (vec-y v2)))))
          v1)

        (defun ,add*! (v x &optional (y x))
          "Destructively update `v` by adding `x` and `y`, returning `v`."
          (declare (type ,element-type y))
          (setf (,vec-type v)
                (values (wrap (+ (vec-x v) x))
                        (wrap (+ (vec-y v) y))))
          v)

        (defun ,sub (v1 v2)
          "Subtract `v1` and `v2` componentwise, returning a new vector."
          (vec (wrap (- (vec-x v1) (vec-x v2)))
               (wrap (- (vec-y v1) (vec-y v2)))))

        (defun ,sub* (v x &optional (y x))
          "Subtract `x` and `y` from the components of `v`, returning a new vector."
          (declare (type ,element-type y))
          (vec (wrap (- (vec-x v) x))
               (wrap (- (vec-y v) y))))

        (defun ,sub! (v1 v2)
          "Destructively update `v1` by subtracting `v2` componentwise, returning `v1`."
          (setf (,vec-type v1)
                (values (wrap (- (vec-x v1) (vec-x v2)))
                        (wrap (- (vec-y v1) (vec-y v2)))))
          v1)

        (defun ,sub*! (v x &optional (y x))
          "Destructively update `v` by subtracting `x` and `y`, returning `v`."
          (declare (type ,element-type y))
          (setf (,vec-type v)
                (values (wrap (- (vec-x v) x))
                        (wrap (- (vec-y v) y))))
          v)

        (defun ,mul (v scalar)
          "Multiply the components of `v` by `scalar`, returning a new vector."
          (vec (wrap (* (vec-x v) scalar))
               (wrap (* (vec-y v) scalar))))

        (defun ,mul! (v scalar)
          "Destructively multiply the components of `v` by `scalar`, returning `v`."
          (setf (,vec-type v)
                (values (wrap (* (vec-x v) scalar))
                        (wrap (* (vec-y v) scalar))))
          v)

        (defun ,div (v scalar)
          "Divide the components of `v` by `scalar`, returning a new vector."
          (vec (wrap (// (vec-x v) scalar))
               (wrap (// (vec-y v) scalar))))

        (defun ,div! (v scalar)
          "Destructively divide the components of `v` by `scalar`, returning `v`."
          (setf (,vec-type v)
                (values (wrap (// (vec-x v) scalar))
                        (wrap (// (vec-y v) scalar))))
          v)

        (defuns (,magnitude ,length) (v)
          "Return the magnitude of `v`."
          (sqrt (+ (square (vec-x v))
                   (square (vec-y v)))))

        (defuns (,angle ,direction) (v)
          "Return the angle of `v`."
          (atan (vec-y v) (vec-x v)))

        (defun ,abs (v)
          "Take the absolute value of each component of `v`, returning a new vector."
          (vec (wrap (abs (vec-x v)))
               (wrap (abs (vec-y v)))))

        (defun ,abs! (v)
          "Destructively update the value of each component of `v` with its absolute value."
          (setf (,vec-type v)
                (values (wrap (abs (vec-x v)))
                        (wrap (abs (vec-y v)))))
          v)

        (define-swizzle ,vec-type x y)))))


(defvec2ops vec2 real)

(defvec2ops vec2f single-float)
(defvec2ops vec2d double-float)

(defvec2ops vec2i integer)
(defvec2ops vec2s fixnum)
(defvec2ops vec2u unsigned-fixnum)

(defvec2ops vec2u8 (unsigned-byte 8))
(defvec2ops vec2u16 (unsigned-byte 16))
(defvec2ops vec2u32 (unsigned-byte 32))
(defvec2ops vec2u64 (unsigned-byte 64))

(defvec2ops vec2s8 (signed-byte 8))
(defvec2ops vec2s16 (signed-byte 16))
(defvec2ops vec2s32 (signed-byte 32))
(defvec2ops vec2s64 (signed-byte 64))

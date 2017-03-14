(asdf:defsystem #:vex
  :name "vex"
  :description "Yet another vector math library."

  :author "Steve Losh <steve@stevelosh.com>"

  :license "MIT"
  :version "0.0.1"

  :depends-on ()

  :serial t
  :components ((:module "vendor"
                :components ((:file "quickutils")))
               (:file "package")
               (:module "src"
                :serial t
                :components ((:file "vectors"))))

  :in-order-to ((asdf:test-op (asdf:test-op #:vex-test))))


(asdf:defsystem #:vex-test
  :name "vex-test"

  :depends-on (#:1am)

  :serial t
  :components ((:file "package-test")
               (:module "test"
                :serial t
                :components ((:file "vectors"))))

  :perform (asdf:test-op
             (op system)
             (uiop:symbol-call :vex-test :run-tests)))

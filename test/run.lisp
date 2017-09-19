#+ecl (setf compiler:*user-cc-flags* "-Wno-shift-negative-value")

(ql:quickload 'vex)
(time (asdf:test-system 'vex))
(quit)

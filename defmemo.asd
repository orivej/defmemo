(asdf:defsystem defmemo
  :version "0.9"
  :description "Memoizing defun"
  :author "Orivej Desh <orivej@gmx.fr>"
  :licence "Unlicense <http://unlicense.org/UNLICENSE>"
  :depends-on (alexandria trivial-garbage)
  :in-order-to ((test-op (load-op defmemo-test)))
  :serial t
  :components ((:file "package") (:file "defmemo")))

(asdf:defsystem defmemo-test
  :depends-on (defmemo)
  :components ((:file "test")))

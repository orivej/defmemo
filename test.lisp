(in-package #:defmemo)

(defmemo fib (n)
  ;; nothing fancy
  (if (<= n 1)
      1
      (+ (fib (- n 1))
         (fib (- n 2)))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  ;; silence future redefinition
  (unintern 'fib))

(assert
 (eq
  (defmemo fib (n &key (fib1 1))
    "test"
    (declare (optimize (space 0)))
    (if (<= n 1)
        fib1
        (+ (fib (- n 1))
           (fib (- n 2)))))
  'fib))

(assert (eql (fib 100) 573147844013817084101))

(assert (equal (documentation 'fib 'function) "test"))

(assert (zerop (hash-table-count (clear-memo 'fib))))

(unintern 'fib)

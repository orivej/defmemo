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

(assert (get-memo 'fib))

(assert (zerop (hash-table-count (clear-memo 'fib))))

(unintern 'fib)

(defmemo test1 (&key nd (d1 1) (d2 2))
  (list nd d1 d2))

(defmemo test2 (&key nd (d1 1) (d2 2))
  (list d2 d1 nd))

(setf (get-memo 'test2) (get-memo 'test1))

(test1 :d1 2 :d2 3)
(test2 :d2 3 :d1 2)

(assert (= 1 (hash-table-count (get-memo 'test2))))

(test1 :d1 4 :d2 5)

(assert (= 2 (hash-table-count (get-memo 'test2))))

(unintern 'test1)
(unintern 'test2)

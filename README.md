defmemo
=======

Defmemo is a generic defun form, performimng memoization other calls
to such defined function.  It supports arbitrary lambda lists and
multiple return values.  (optimize speed)-friendly, otherwise it might
have been implemented as in Peter Norvig's PAIP.  Preserves arguments
and documentation.  Memoizing hash

## Usage

Three functions are exported: defmemo (like defun), clear-memo
(defmemo`d symbol) and memoize (funcallable object).  Clear-memo is
not needed on implementations supporting weak tables (via
trivial-garbage).  Memoize is not needed for primary use-cases.

```lisp
(defmemo fib (n)
  (if (<= n 1)
      1
      (+ (fib (- n 1))
         (fib (- n 2)))))

(fib 100)
; => 573147844013817084101

(hash-table-count (clear-memo 'fib))
; => 0
```

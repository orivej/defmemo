(in-package #:defmemo)

(defun get-memo (symbol)
  "Get memoizing hash table."
  (get symbol :memo))

(defun (setf get-memo) (value symbol)
  "Replace memoizing hash of symbol with value."
  (setf (get symbol :memo) value))

(defun clear-memo (symbol)
  "Reset memoizing hash table."
  (let ((memo (get-memo symbol)))
    (when memo (clrhash memo))))

(defun flat-arglist (args)
  "Convert ordinary lambda list into funcallable list."
  (multiple-value-bind (required optional rest keywords)
      (parse-ordinary-lambda-list args)
    (flatten
     (list required
           (mapcar #'first optional)
           (list rest)
           (mapcar #'first keywords)))))

(defmacro defmemo (name args &body body)
  "Construct defun with body wrapped into memoizing hash table.  Put the latter under :memo property of name."
  (let ((arglist (flat-arglist args)))
    (multiple-value-bind (body decls doc) (parse-body body :documentation t)
      (with-gensyms (entry present)
        `(progn
           (setf (get-memo ',name)
                 (make-weak-hash-table
                  :test #'equal :weakness :key :weakness-matters nil))
           (defun ,name ,args
             ,@(and doc (list doc))
             ,@decls
             (multiple-value-bind (,entry ,present)
                 (gethash (list . ,arglist) (get-memo ',name))
               (values-list
                (if ,present ,entry
                    (setf (gethash (list . ,arglist) (get-memo ',name) )
                          (multiple-value-list
                           (block ,name . ,body))))))))))))

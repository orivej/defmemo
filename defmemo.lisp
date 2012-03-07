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

(defun doc-decls-body (body)
  "Extract documentation, declarations and pure body from body."
  (let (doc decls)
    (when (stringp (first body))
      (setf doc (first body)
            body (rest body)))
    (when (eq (caar body) 'declare)
      (setf decls (first body)
            body (rest body)))
    (values doc decls body)))

(defmacro defmemo (name args &body body)
  "Construct defun with body wrapped into memoizing hash table.  Put the latter under :memo property of name."
  (let ((arglist (flat-arglist args)))
    (multiple-value-bind (doc decls body) (doc-decls-body body)
      (with-gensyms (entry present)
        `(progn
           (setf (get-memo ',name)
                 (make-weak-hash-table
                  :test #'equal :weakness :key :weakness-matters nil))
           (defun ,name ,args
             ,doc
             ,decls
             (multiple-value-bind (,entry ,present)
                 (gethash (list . ,arglist) (get-memo ',name))
               (values-list
                (if ,present ,entry
                    (setf (gethash (list . ,arglist) (get-memo ',name) )
                          (multiple-value-list
                           (block ,name . ,body))))))))))))

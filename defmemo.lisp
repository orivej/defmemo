(in-package #:defmemo)

(defun memoize (function)
  "Wrap function into memoizing lambda.  Return values: lambda and memo hash."
  (let ((memo (make-weak-hash-table
               :test #'equal :weakness :key :weakness-matters nil)))
    (values
     (lambda (&rest args)
       (multiple-value-bind (v p) (gethash args memo)
         (values-list
          (if p v (setf (gethash args memo)
                        (multiple-value-list (apply function args)))))))
     memo)))

(defmacro defmemo (name args &body body)
  "Insert body into flet, memoize it and defun resulting lambda under name."
  (multiple-value-bind (required optional rest keywords)
      (parse-ordinary-lambda-list args)
    (let ((arglist (flatten
                    (list required
                          (mapcar #'first optional)
                          (list rest)
                          (mapcar #'first keywords))))
          (docstring (and (stringp (first body))
                          (first body))))
      (with-gensyms (fun memo)
        `(flet ((,fun ,args . ,body))
           (multiple-value-bind (,fun ,memo)
               (memoize #',fun)
             (setf (get ',name :memo) ,memo)
             (defun ,name ,args
               ,docstring
               (funcall ,fun . ,arglist))))))))

(defun get-memo (symbol)
  "Get memoizing hash table"
  (get symbol :memo))

(defun clear-memo (symbol)
  "Reset memoizing hash table"
  (let ((memo (get-memo symbol)))
    (when memo (clrhash memo))))

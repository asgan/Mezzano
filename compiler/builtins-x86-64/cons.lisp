;;;; Copyright (c) 2011-2015 Henry Harrington <henry.harrington@gmail.com>
;;;; This code is licensed under the MIT license.

;;;; Builtin functions for dealing with conses.

(in-package :mezzano.compiler.codegen.x86-64)

(define-tag-type-predicate consp sys.int::+tag-cons+)

(defbuiltin car (list) ()
  (let ((type-error-label (gensym))
        (out-label (gensym)))
    (emit-trailer (type-error-label)
      (raise-type-error :r8 'list))
    (load-in-reg :r8 list t)
    (smash-r8)
    (emit `(sys.lap-x86:cmp64 :r8 nil)
          `(sys.lap-x86:je ,out-label)
          `(sys.lap-x86:mov8 :al :r8l)
          `(sys.lap-x86:and8 :al #b1111)
          `(sys.lap-x86:cmp8 :al ,sys.int::+tag-cons+)
          `(sys.lap-x86:jne ,type-error-label)
          `(sys.lap-x86:mov64 :r8 (:car :r8))
          out-label)
    (setf *r8-value* (list (gensym)))))

(defbuiltin cdr (list) ()
  (let ((type-error-label (gensym))
        (out-label (gensym)))
    (emit-trailer (type-error-label)
      (raise-type-error :r8 'list))
    (load-in-reg :r8 list t)
    (smash-r8)
    (emit `(sys.lap-x86:cmp64 :r8 nil)
          `(sys.lap-x86:je ,out-label)
          `(sys.lap-x86:mov8 :al :r8l)
          `(sys.lap-x86:and8 :al #b1111)
          `(sys.lap-x86:cmp8 :al ,sys.int::+tag-cons+)
          `(sys.lap-x86:jne ,type-error-label)
          `(sys.lap-x86:mov64 :r8 (:cdr :r8))
          out-label)
    (setf *r8-value* (list (gensym)))))

(defbuiltin (setf car) (value object) ()
  (load-in-reg :r9 object t)
  (load-in-reg :r8 value t)
  (emit-tag-check :r9 sys.int::+tag-cons+ 'cons)
  (emit `(sys.lap-x86:mov64 (:car :r9) :r8))
  *r8-value*)

(defbuiltin (setf cdr) (value object) ()
  (load-in-reg :r9 object t)
  (load-in-reg :r8 value t)
  (emit-tag-check :r9 sys.int::+tag-cons+ 'cons)
  (emit `(sys.lap-x86:mov64 (:cdr :r9) :r8))
  *r8-value*)
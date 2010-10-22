#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")
(require "filter-list.rkt")

(define-struct applicant (id name rating))

(define (app-world applicant)
  (async-js-big-bang
   applicant
   (on-draw
    (lambda (applicant)
      (list (js-div)
            (list (js-text (applicant-name applicant)))
            (list (js-text (number->string 
                            (applicant-rating applicant)))))))))

(define a1 (make-applicant 0 "Bob" 5))
(define a2 (make-applicant 1 "Frank" 5))
(define a3 (make-applicant 2 "Suzie" 10))
(define a4 (make-applicant 3 "Teddy" 9))

(define app-list `(,a1 ,a2 ,a3 ,a4))

(define apphash (make-hash))

(define _ (map (lambda (app)
                 (hash-set! apphash (applicant-id app) (app-world app)))
               app-list))

(define flist (make-filter-list apphash
                                '(0 1 2)))

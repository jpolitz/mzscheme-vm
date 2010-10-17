#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(require "lazy-list.rkt"
         "counter-widget.rkt")

(define (nums n)
  (define (nums_ acc)
    (if (= n acc)
        (cons n empty)
        (cons acc (nums_ (+ acc 1)))))
  (nums_ 0))

(define loaders
  (map (lambda (n)
         (lambda ()
           (make-counter 0)))
       (nums 50)))

(make-list-widget loaders 0 10)
#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define (count-up-10 n)
  (js-big-bang
   n
   (on-tick add1 .5)
   (stop-when (lambda (w) (>= w (+ n 10))))))

(define (count-by-twos n)
  (js-big-bang
   n
   (on-tick (lambda (w) (+ 2 w)) 1)
   (stop-when (lambda (w) (>= w (+ n 10))))))
  

;(count-up-10 0)
;(count-up-10 (count-by-twos 0))

(display "Done")

(define _ (async-js-big-bang
          0
          (name "async")
          (on-tick (lambda (w) (begin (display (format "World is: ~a" w))
                                     (count-up-10 w)))
                   1)
        (stop-when (lambda (w) (> w 100)))));

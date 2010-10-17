#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(provide make-counter)

(define (make-counter (start 0))
  (async-js-big-bang
   start
   (on-tick add1 1)
   (on-draw (lambda (n)
              (list (js-text (number->string n)))))))
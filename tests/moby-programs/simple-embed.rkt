#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define b1
  (async-js-big-bang
   0
   (on-tick add1 2)
   (on-draw (lambda (w) 
              (list (js-div)
                    (list (js-text (number->string w))))))))

(define b2
  (async-js-big-bang
   10
   (on-tick add1 1)
   (on-draw (lambda (w)
              (list (js-div)
                    (list (js-text (number->string w)))
                    (list (embed-world b1)))))))
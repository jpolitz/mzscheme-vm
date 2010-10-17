#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(provide pending-widget)

(define (pending-widget message (wait .3))
  (async-js-big-bang
   `(,message 1)
   (on-tick (lambda (w)
              `(,(string-append message (make-string (second w) #\.))
                ,(modulo (add1 (second w)) 4)))
            wait)
   (on-draw (lambda (w)
              (list (js-text (first w)))))))


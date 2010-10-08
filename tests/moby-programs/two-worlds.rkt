#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")




(define b2 (async-js-big-bang
                                           
            b1

            10
            
            (on-draw (lambda (w)
                       (list (js-div)
                             (list (js-text (number->string w)))))
                     (lambda (w)
                       '()))
            
            (on-tick add1 1)))

(define b1 (async-js-big-bang

            0

            (on-draw (lambda (w)
                       (list (js-div)
                             (list (js-div)
                                   (list (js-text (string-append "This number is: " (number->string w))))
                                   (list (embed-world b2))))))
            
            (on-tick add1 1)
            
            (stop-when (lambda (w) (> w 10)))))


  "Last line"

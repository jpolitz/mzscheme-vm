#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")


(define w1 (async-js-big-bang
            0
            (on-msg (lambda (w from msg)
                      msg))
            (on-draw (lambda (w)
                       (list (js-div)
                             (list (js-text (format "The last message I got was: ~a" w))))))))


(define w2 (async-js-big-bang
            5
            (on-tick (lambda (w) (make-parcel (add1 w)
                                              '()
                                              (list (make-mail w1 (* w 10)))))
                     1)))

"Last Line"
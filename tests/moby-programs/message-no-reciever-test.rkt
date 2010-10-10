#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")


(define w1 (async-js-big-bang 0 (on-tick add1 1)))

(define w2 (async-js-big-bang
            5
            (on-tick (lambda (w) (make-parcel (add1 w)
                                              (list (make-mail w1 (* w 10)))))
                     1)))

"Last Line"
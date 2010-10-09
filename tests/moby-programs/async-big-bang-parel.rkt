#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define b1 (async-js-big-bang 0 (on-tick add1 1)))
(define b2 (async-js-big-bang 0

                     (on-tick (lambda (w)
                                (make-parcel (add1 w)
                                             (list (make-mail b1 w))))
                              1)))

"Last line"

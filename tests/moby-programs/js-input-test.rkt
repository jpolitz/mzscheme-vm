#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define input
  (js-input "text"
            (lambda (w v) v)
            '()))

(define (draw w)
  (list (js-div)
        (list input)
        (list (js-text w))))

(define _ (async-js-big-bang
           ""
           (on-draw draw)))

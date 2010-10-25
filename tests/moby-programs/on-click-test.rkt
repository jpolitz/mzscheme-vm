#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define (draw-html w)
  (list (js-div)
        (list (js-a `(("href" "#")
                      ("click" ,(lambda (w e) (add1 w)))))
              (list (js-text "Click Here!")))
        (list (js-text (format "Click Count: ~s" w)))))

(define _ (async-js-big-bang 0 (on-draw draw-html)))

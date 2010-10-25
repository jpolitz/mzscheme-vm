#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define (draw-html w)
  (list (js-div `(("className" "widget")
                  ("click" ,(lambda (w e) (add1 w)))))
        (list (js-text (format "Box Click Count: ~s" w)))))

(define (draw-css w)
  '((".widget" ("border" "2px dashed"))))


(define _
  (async-js-big-bang 0
                     (on-draw draw-html draw-css)))

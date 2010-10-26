#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define the-text-box
  (js-input "text" (lambda (w v)
                     (if (equal? v "")
                         '()
                         (make-parcel w
                                      `(("send-effect" ,v))
                                      '())))
            '(("value" ""))))

(define (draw w)
  (cons (js-div)
        (cons (list the-text-box)
              (map (lambda (elt) (list (js-text elt))) w))))
        

(define _
  (async-js-big-bang '()
                     (name "something")
                     (on-draw draw)
                     (on-server-msg (lambda (w msg) msg))))

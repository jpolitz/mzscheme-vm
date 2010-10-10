#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

; Ping pong messages between w1 and w2 as quickly as possible.

(define w1
  (async-js-big-bang 0
                     (on-msg (lambda (w from msg)
                               (make-parcel (add1 w)
                                            (list (make-mail from "reply")))))
                     (on-draw (lambda (w)
                                (list (js-div)
                                      (list (js-text (format "Messages: ~a" w))))))))


(define-struct ws (ticks msgs))

(define w2
  (async-js-big-bang (ws 0 0)
                     (on-tick (lambda (w)
                                (let ([w (make-ws (add1 (ws-ticks w)) (ws-msgs w))])
                                  (if (= 1 (ws-ticks w))
                                     ; send a message on first tick only
                                      (make-parcel w (list (make-mail w1 "msg")))
                                      w)))
                              1)
                     (on-msg (lambda (w from msg)
                               (make-parcel (make-ws (ws-ticks w) (add1 (ws-msgs w)))
                                            (list (make-mail from "reply")))))
                     (on-draw (lambda (w)
                                (list (js-div)
                                      (list (js-text (format "Ticks: ~a" (ws-ticks w))))
                                      (list (js-text (format "Messages: ~a" (ws-msgs w)))))))
                     ))
                     
"Last Line"

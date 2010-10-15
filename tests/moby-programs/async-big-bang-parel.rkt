#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")


(define (string-world w)
  (list (js-div)
        (list (js-text w))))
  

(define b1 
  (async-js-big-bang 

   ""

   (on-msg (lambda (world from msg) msg))
   
   (on-draw string-world)))



(define b2 
  (async-js-big-bang 

   0
                     
   (name "something")
   
   (on-tick (lambda (w)
              (make-parcel w
                           '(("get-client-data"))
                                             '()))
            1)
   
   (on-server-msg (lambda (w m)
                    (make-parcel (add1 w)
                                 '()
                                 `(,(make-mail b1 m)))))
   
   (on-draw (lambda (w)
              (list (js-div)
                    (list (js-text (number->string w)))
                    (list (embed-world b1)))))))

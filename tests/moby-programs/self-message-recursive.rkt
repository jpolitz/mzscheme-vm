#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

;; Warning --- this is an infinite loop

(define world
 
  (async-js-big-bang

   0

   (on-tick (lambda (w)
              (make-parcel w
                           (list (make-mail world (add1 w)))))
            1)

   (on-msg (lambda (w from msg)
             (make-parcel msg
                          (list (make-mail world (add1 msg))))))))


#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define world
 
  (async-js-big-bang

   0

   (on-tick (lambda (w)
              (make-parcel w
                           (list (make-mail world (add1 w)))))
            1)

   (on-msg (lambda (w msg)
             msg))))


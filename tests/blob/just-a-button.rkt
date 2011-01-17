#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))
(require "../../src/blobs/blob-macros.rkt")

(define myblob
  (let* ([button (button-blob "Add a click")]
         [make-div (lambda (w) (div `(,(format "~a clicks" (number->string w)) ,button)))])
    (blob 0
          ('main (lambda (w the-world)
                   (let* ([div (make-div w)]
                          [div-drawer (make-to-screen (GET-TOP-SCREEN) myblob)])
                     (handler-complete w 
                                       `(,(signal 'on-screen div))
                                       `(,(register button 'on-button))
                                       `(,(introduce div-drawer))))))
          ('on-button (lambda (w click-value)
                        (let* ([w (add1 w)]
                               [div (make-div w)])
                          (handler-complete w
                                            `(,(signal 'on-screen div)))))))))
  

(primitive-send myblob 'main (MAKE-THE-WORLD))

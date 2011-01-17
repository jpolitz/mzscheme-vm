#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))
(require "../../src/blobs/blob-macros.rkt")

(define foo
  (blob 0
        ('main (lambda (w the-world)
                (let ([screen (make-to-screen '() foo)])
                  (handler-complete w 
                                    `(,(signal 'on-screen (button-blob "A button!")))
                                    '()
                                    `(,(introduce screen))))))))

(primitive-send foo 'main (MAKE-THE-WORLD))

#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))

(require "../../src/blobs/blob-macros.rkt")

(define myblob
  (blob 5 
        ('main (lambda (w world)
                 (handler-complete w '()
                                   `(,(register world "on-key")))))
        ('on-key (lambda (w k) 
                   (display (string-append "did it: " (number->string w) "\n"))
                   (handler-complete (add1 w))))))

(primitive-send myblob 'main (MAKE-THE-WORLD))





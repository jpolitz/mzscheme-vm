#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))

(require "../../src/blobs/blob.rkt")

(define world (MAKE-THE-WORLD))

(define myblob
  (blob 5 
        (on-key (lambda (w k) 
                  (display "did it")
                  (add1 w)))))

(display myblob)

(register world myblob "on-key")


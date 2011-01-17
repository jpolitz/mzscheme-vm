#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))
(require "../../src/blobs/blob-macros.rkt")

(define (make-incrementer sourceblob)
  (blob 0
        ('init (lambda (w _) (handler-result w '() 
                                             `(,(register sourceblob 'on-increment)))))
        ('increment (lambda (w _)
                      (handler-result (add1 w) 
                                      `((,signal 'incremented (add1 w))))))))

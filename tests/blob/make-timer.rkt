#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))
(require "../../src/blobs/blob-macros.rkt")

(define foo
  (blob 0
        ('main (lambda (w the-world)
                 (let ([timer (make-timer 100)])
                   (handler-complete w '() `(,(register timer "on-tick"))))))
        ('on-tick (lambda (w t)
                    (display (format "Tick: ~a\n" (add1 w)))
                    (handler-complete (add1 w))))))

(primitive-send foo 'main (MAKE-THE-WORLD))

                   
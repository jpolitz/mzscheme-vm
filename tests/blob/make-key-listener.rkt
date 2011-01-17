#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))
(require "../../src/blobs/blob-macros.rkt")

(define (make-key-listener keysource key)
  (blob '()
        ('init (lambda (w _)
                 (handler-complete '() '()
                                   `(,(register keysource "on-key")))))
        ('on-key (lambda (w thiskey)
                   (begin
                     (display (format "Got key: ~a\n" thiskey))
                     (handler-complete '()
                                       (if (key=? key thiskey)
                                           `(,(signal "on-key" thiskey))
                                           `())))))))

(define foo
  (blob '_
        ('main (lambda (w the-world)
                 (let ([m-listener (make-key-listener the-world 'm)]
                       [drawer (make-to-screen '() foo)])
                   (handler-complete w '() ;; no signals
                                     `(,(register m-listener "on-key"))
                                     `(,(introduce m-listener)
                                       ,(introduce drawer))))))
        ('on-key (lambda (w m)
                   (begin
                     (display (format "Main got key: ~a\n" m))
                     (handler-complete w `(,(signal "on-screen" "data"))))))))

(primitive-send foo 'main (MAKE-THE-WORLD))

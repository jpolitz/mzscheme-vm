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
                     (handler-complete '()
                                       (if (key=? key thiskey)
                                           `(,(signal "on-key" thiskey))
                                           `())))))))

(define foo
  (blob '_
        ('main (lambda (w the-world)
                 (let ([m-listener (make-key-listener the-world 'm)]
                       [drawer (make-to-screen (GET-TOP-SCREEN) foo)])
                   (handler-complete w '() ;; no signals yet
                                     `(,(register m-listener "on-key"))
                                     `(,(introduce m-listener)
                                       ,(introduce drawer))))))
        ('on-key (lambda (w m)
                     (handler-complete w `(,(signal 'on-screen (div `(,(format "Main got key: ~a\n" m))))))))))

(primitive-send foo 'main (MAKE-THE-WORLD))

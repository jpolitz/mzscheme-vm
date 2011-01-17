#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))
(require "../../src/blobs/blob-macros.rkt")

;; This allows us to restrict the message of type source-message
;; from source, and have it be stopped by controller
(define (make-gatekeeper controller source source-message (stop-message 'stop))
  (blob #t
        ('init (lambda (w init-arg)
                 (handler-complete w
                                   '()
                                   `(,(register source message)
                                     ,(register controller 'stop)))))
        (message (lambda (w handler-arg)
                   (let ([signals (if w `(,(signal message handler-arg)) '())])
                     (handler-complete w
                                       signals))))
        (stop-message (lambda (w stop-arg)
                        (handler-complete #f)))))

;; This restricts our output to a single message
(define (view-only blob message)
  (blob '()
        ('init (lambda (w init-arg)
                 (handler-complete w '() `(,(register blob message)))))
        (message (lambda (w handler-arg)
                   (handler-complete w `(,(signal message hander-arg)))))))
  
;; Can we forward the rest of the signature of blob?
(define (transform blob message f)
  (blob '()
        ('init (lambda (w init-arg)
                 (handler-complete w '() `(,(register blob message)))))
        (message f)))


(define foo
  (blob 0
        ('main (lambda (w the-world)
                 (let ([the-div (div-blob (number->string w))]
                       [the-button (button-blob "Stop!")]
                       [the-timer (make-timer 1000)]
                       [the-screen (make-to-screen '() foo)])
                   (handler-complete w
                                     '()
                                     `(,(register the-button "on-click")
                                       `(register the-timer "on-tick"))
                                     `(,(introduce the-timer)
                                       ,(introduce the-button)
                                       ,(introduce the-div)
                                       ,(introduce the-screen))))))
        
        ('on-tick (lambda (w t)
                    

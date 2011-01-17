#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))

(require "../../src/jsworld/jsworld.rkt")

(define h (blob-handler 0 0))

(display h)

(define b (blob-impl2 5))

(display b)


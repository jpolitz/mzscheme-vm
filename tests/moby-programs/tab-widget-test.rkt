#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(require "tab-widget.rkt")
(require "counter-widget.rkt")

(define t1 (make-counter))

(define t2 (make-counter 1000))

(define tabs (list (list "tab1" t1) (list "tab2" t2)))

(define w (make-tab-widget tabs t1))

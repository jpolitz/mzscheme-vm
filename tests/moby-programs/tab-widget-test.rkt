#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(require "tab-widget.rkt")
(require "pending-widget.rkt")

(define t1 (lambda () (pending-widget "Tab1")))

(define t2 (lambda () (pending-widget "Tab2")))

(define tabs (list (list "tab1" t1) (list "tab2" t2)))

(define w (make-tab-widget tabs t1))

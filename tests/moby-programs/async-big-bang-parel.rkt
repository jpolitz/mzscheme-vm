#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")


(define b1 (async-js-big-bang ""

                              (on-msg (lambda (w from m)
                                        m))))
                                        
(define b2 (async-js-big-bang 0

                              (name "something")

                              (on-tick (lambda (w)
                                         (make-parcel w
                                                      '(("get-client-data"))
                                                      '()))
                                       1)

                              (on-server-msg (lambda (w m)
                                               (make-parcel (add1 w)
                                                            '()
                                                            (list (make-mail b1 m)))))))


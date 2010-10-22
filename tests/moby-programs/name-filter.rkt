#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(provide make-name-filter)

(define (make-name-filter name-lookup handler)
  (define input
    (js-input "text"
              (lambda (w v) 
                (make-parcel v
                             '()
                             (list (make-mail handler
                                              `("filter-for" "name-filter" 
                                                ,(lambda (item)
                                                   (or (equal? v "")
                                                       (equal? (name-lookup item) v))))))))
              '(("value" ""))))

  (define (draw w)
    (list (js-div '(("id" "name-filter")))
          (list (js-text "Name:"))
          (list input)))

  (define (draw-css w)
    `("name-filter"
      (("display" "block"))))

  (async-js-big-bang
   ""
   (on-draw draw draw-css)))

#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(provide make-range-filter)

(define (make-range-filter label range-lookup min max handler)

  (define (mk-filter range)
    (lambda (item)
      (let ([val (range-lookup item)])
        (and (<= (car range) val) (>= (cdr range) val)))))

  (define (mk-input new-world)
    (js-input "text"
              (lambda (w v)
                (make-parcel (new-world w v)
                             '()
                             (list (make-mail handler
                                              `("filter-for" "range-filter"
                                                ,(mk-filter (new-world w v)))))))
              '()))

  (define (chk-str str) (and (not (equal? str "")) (string->number str)))
  (define low-input (mk-input (lambda (w v) 
                                (cons (or (chk-str v) min) (cdr w)))))
  (define high-input (mk-input (lambda (w v) 
                                 (cons (car w) (or (chk-str v) max)))))

  (define (draw w)
    (list (js-div)
          (list (js-text label))
          (list low-input)
          (list high-input)))

  (async-js-big-bang
   (cons min max)
   (on-draw draw)))
   
   

                 
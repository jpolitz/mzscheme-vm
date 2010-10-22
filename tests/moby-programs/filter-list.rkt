#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(provide make-filter-list)

;; A list widget that listens to "filter" messages

;; a f-list is a (make-f-list (hashof (number? : world?)) (listof number?))
(define-struct f-list (elts to-show))

(define (make-filter-list elts (to-show (hash-map elts (lambda (k v) k))))

   ;; listens to messages that look like ("filter" . (listof number?))
   ;; and no others
  (define (message a-f-list from msg)
    (if (equal? (car msg) "filter")
        (make-f-list elts (cdr msg))
        a-f-list))

  (define (draw-css a-f-list)
    `((".filter-item"
       ("border" "2px dashed")
       ("width" "10%"))))

  ;; draw only the items keyed in the list
  (define (draw a-f-list)
    (let ([elts (f-list-elts a-f-list)])
      (cons (js-div)
            (map (lambda (k) 
                   (list (js-div '(("className" "filter-item")))
                         (list (embed-world (hash-ref elts k))))) 
                 (f-list-to-show a-f-list)))))

  (async-js-big-bang 

   (make-f-list elts to-show)

   (on-msg message)

   (on-draw draw draw-css)))
                 
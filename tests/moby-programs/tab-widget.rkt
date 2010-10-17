#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(provide tab-world make-tab-widget)

(define-struct tab-world (tabs current-tab))

(define (make-tab-widget tabs (start-tab (second (first tabs))))

  (define (tab-names tabs)
    (map (lambda (tab-record)
           (list 
            (js-button (lambda (tab-world e)
                         (make-tab-world tabs (second tab-record))))
                         
            (list (js-text (first tab-record)))))
         tabs))

  (define (insert-or-invoke tab-or-fn)
    (cond [(procedure? tab-or-fn) (tab-or-fn)]
          [else tab-or-fn]))

  (async-js-big-bang
   (make-tab-world tabs start-tab)

   (on-draw
    (lambda (tab-world)
      (list (js-div '())

            (cons (js-div '())
                  
                  (tab-names tabs))

            (list (js-div '())

                  (list (embed-world (insert-or-invoke (tab-world-current-tab tab-world))))))))

   ;; accept messages like '("change-tab" tab-name) to change to
   ;; different tabs
   (on-msg
    (lambda (tab-world msg)

      (if (equal? (first msg) "change-tab")
          (let ([maybe-new-tab (assoc (second msg) tabs)])
            (if maybe-new-tab
                (make-tab-world tabs (second maybe-new-tab))
                tab-world))
          tab-world)))))


         
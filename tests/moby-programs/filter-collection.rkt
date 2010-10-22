#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(provide make-filter-collection)

(define-struct filters (funs worlds receivers))

;; msg should look like
;; ("filter-for" filter-id procedure?)
(define (message filters from msg)
  (cond [(equal? (first msg) "filter-for")
         (begin (hash-set! (filters-funs filters) (second msg) (third msg))
                (make-parcel 
                 filters
                 '()
                 (map (lambda (w) 
                        (make-mail w 
                                   (cons "filter"
                                         (lambda (item)
                                           (empty?
                                            (filter
                                             (lambda (x) x)
                                             (hash-map (filters-funs filters)
                                                       (lambda (k fun)
                                                         (if (fun item) #f item)))))))))
                      (filters-receivers filters))))]
        [(equal? (first msg) "new-filter")
         (make-filters (filters-funs filters)
                       (cons (second msg) (filters-worlds filters))
                       (filters-receivers filters))]
        [(equal? (first msg) "new-receiver")
         (make-filters (filters-funs filters)
                       (filters-worlds filters)
                       (cons (second msg) (filters-receivers filters)))]
        [else filters]))

(define (draw filters)
  (cons (js-div)
        (map (lambda (world)
               (list (js-div '(("className" "filter")))
                     (list (embed-world world))))
             (filters-worlds filters))))

(define (make-filter-collection funs worlds receivers)

  (async-js-big-bang

   (make-filters funs worlds receivers)

   (on-draw draw)
   (on-msg message)))


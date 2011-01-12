#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")
(require "filter-list.rkt"
         "filter-collection.rkt"
         "name-filter.rkt"
         "range-filter.rkt")

(define-struct applicant (id name rating))

(define (app-world applicant)
  (async-js-big-bang
   applicant
   (on-draw
    (lambda (applicant)
      (list (js-div)
            (list (js-text (applicant-name applicant)))
            (list (js-text (string-append
                            "Rating: "
                            (number->string 
                             (applicant-rating applicant))))))))))

(define a1 (make-applicant 0 "Bob" 5))
(define a2 (make-applicant 1 "Frank" 5))
(define a3 (make-applicant 2 "Suzie" 10))
(define a4 (make-applicant 3 "Teddy" 9))

(define app-list `(,a1 ,a2 ,a3 ,a4))

(define apphash (make-hash))

(define _ (map (lambda (app)
                 (hash-set! apphash (applicant-id app) (app-world app)))
               app-list))

(define flist (make-filter-list apphash
                                '(0 1 2)))

(define collection (make-filter-collection (make-hash) '() '()))
(define namefilt (make-name-filter applicant-name collection))
(define rangefilt (make-range-filter "Rating" applicant-rating 0 10 collection))

(define (filterer source sink)
    (async-js-big-bang
     app-list
     (on-draw (lambda (w) (list (js-div))))
     (on-msg (lambda (w from msg)
               (if (equal? (car msg) "filter")
                   (let* ([filtered (filter (cdr msg) app-list)]
                          [filtered-ids (map applicant-id filtered)])
                     (make-parcel 
                      w
                      '()
                      (list (make-mail sink (cons "filter" filtered-ids)))))
                   w)))))


(define (top)

  (define the-filterer (filterer collection flist))

  (define ar (async-js-big-bang

              (make-parcel app-list
                           '()
                           (list (make-mail collection `("new-filter" ,namefilt))
                                 (make-mail collection `("new-filter" ,rangefilt))
                                 (make-mail collection `("new-receiver" ,the-filterer))))
              
              (on-draw (lambda (w)
                         (list (js-div)
                               (list (embed-world collection))
                               (list (embed-world flist)))))))
  ar)

(define top-world (top))


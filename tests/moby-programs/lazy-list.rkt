#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define-struct list-world (current-start
                           number-to-show
                           elements))

(provide make-list-widget)

(define (invoke-or-return world-or-fn)
  (cond [(procedure? world-or-fn) (world-or-fn)]
        [else world-or-fn]))

(define (take l n)
  (if (= n 0)
      empty
      (cons (first l) (take (rest l) (- n 1)))))

(define (drop l n)
  (if (= n 0)
      l
      (drop (rest l) (- n 1))))

(define (elements-in-range elements start to-show)
  (let* ([len (length elements)]
         [takeable (min to-show (- len start))])
    (if (< takeable 0) '()
        (take (drop elements start) takeable))))

(define (next-button number-to-show)
  (list (js-button
         (lambda (list-world evt)
           (let* ([new-start (+ (list-world-current-start list-world)
                                number-to-show)]
                  [new-els (start-elements 
                            (list-world-elements list-world)
                            new-start
                            number-to-show)])
             (make-list-world new-start
                              number-to-show
                              new-els))))
        (list (js-text (string-append "Next " (number->string 
                                               number-to-show))))))

(define (prev-button number-to-show)
  (list (js-button
         (lambda (list-world evt)
           (let* ([new-start (- (list-world-current-start list-world)
                                number-to-show)]
                  [new-els (start-elements 
                            (list-world-elements list-world)
                            new-start
                            number-to-show)])
             (make-list-world new-start
                              number-to-show
                              new-els))))
        (list (js-text (string-append "Prev " (number->string 
                                               number-to-show))))))

(define (draw-elements elements start to-show)
  (map 
   ;; this list should always be evaluated already!
   (lambda (el)
     (list (js-div '())
           (list (embed-world el))))
   (elements-in-range elements start to-show)))

(define (draw list-world)
  (append (cons (js-div '())
                (draw-elements (list-world-elements list-world)
                               (list-world-current-start list-world)
                               (list-world-number-to-show list-world)))
          (list (next-button (list-world-number-to-show list-world))
                (prev-button (list-world-number-to-show list-world)))))

(define (start-elements els start number-to-show)
  (let* ([prefix (take els (min start (length els)))]
         [suffix (drop els (min (length els) (+ start number-to-show)))]
         [firsts (elements-in-range els start number-to-show)])
    (append prefix
            (append (map (lambda (el) (invoke-or-return el)) firsts) suffix))))
    

(define (make-list-widget elements start number-to-show)
  (async-js-big-bang

   (make-list-world start number-to-show 
                    (start-elements elements start number-to-show))
   
   (on-draw draw)

   ))

#lang s-exp "../../src/lang/base.rkt"

(require "../../src/jsworld/jsworld.rkt")

(define (set-css-properties id)
  `(,id
    ("float"      "left")
    ("border"     "dashed 2pt")
    ("text-align" "center")
    ("padding"    "0.5em")
    ("margin"     "0.5em")))

(define-struct stopwatch (paused time))

(define stopwatch-widget
  (local ((define reset-button
            (js-button (lambda (w e)
                         (make-stopwatch (stopwatch-paused w) 0))
                       '(("id" "reset"))))
          (define pause-button
            (js-button (lambda (w e)
                         (make-stopwatch (not (stopwatch-paused w))
                                         (stopwatch-time w)))
                       '(("id" "pause")))))
    (async-js-big-bang

     (make-stopwatch false 0)

     (on-tick (lambda (w)
                (if (stopwatch-paused w)
                    w
                    (make-stopwatch false (add1 (stopwatch-time w)))))
              1)

     (on-draw (lambda (w)
                (list (js-div '(("id" "stopwatchWidget")))
                      (list (js-text "Stopwatch Widget:"))
                      (list (js-text (number->string (stopwatch-time w))))
                      (list pause-button
                            (list (js-text (if (stopwatch-paused w)
                                               "Resume"
                                               "Pause"))))
                      (list reset-button
                            (list (js-text "Reset")))))
              (lambda (w)
                (list (set-css-properties "stopwatchWidget")))))))

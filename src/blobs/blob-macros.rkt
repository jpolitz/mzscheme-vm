#lang s-exp "../../src/lang/base.rkt"

(require (for-syntax racket/base))

(require "jsblob.rkt")

(define-syntax blob
  (syntax-rules ()
    [(blob 
      <init>
      (<callback-name> <callback-lambda>) ...)
     (blob-impl 
      <init>
      (blob-handler <callback-name> <callback-lambda>) ...)]))

(provide blob
         handler-complete
         primitive-send
         MAKE-THE-WORLD
         GET-TOP-SCREEN
         introduce
         signal
         button-blob
         div-blob
         div

         (rename-out (makeToScreen make-to-screen))
         (rename-out (makeTimer make-timer))
         register)

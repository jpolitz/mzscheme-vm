#lang racket
(require redex)

(define-language λB
  (p number string)
  ;; blobs have a value, a list of pending signals, and a list of handlers
  (b (blob (v (p v ...) ...) (h ...) (l ...)))
  ;; handlers say that a blob respond to a signal p with the given function
  (h (p (λ (x ...) e)))
  ;; listener registrations say that a blob listens to messages from another
  (l (p b))
  ;; blobs that don't have any pending signals are values
  (v p (λ (x ...) e)
     (blob (v) (h ...) (l ...))
     x)
  
  (e v b (e e ...))
  
  ((x y f g) (variable-except λ blob))
  
  (E hole
     ;; we can evaluate things in the value position of the blob
     (blob E (h ...) (l ...))
     ;; or we can go into its listeners and evaluate *them*, if there
     ;; are no pending signals from them
     (blob (v) (h ...) ((p_1 (blob (v_1) (h_1 ...) ((p v) ...))) ... 
                        (p_2 E)
                        (p_3 (blob (v_3) (h_3 ...) (l_3 ...))) ...))
     (v ... E e ...)))

(define-metafunction λB
  subst-n : (x any) ... any -> any
  [(subst-n (x_1 any_1) (x_2 any_2) ... any_3)
   (subst x_1 any_1 (subst-n (x_2 any_2) ... any_3))]
  [(subst-n any_3) any_3])

(define-metafunction λB
  subst : x any any -> any
  ;; 1. x_1 bound, so don't continue in λ body
  [(subst x_1 any_1 (λ (x_2 ... x_1 x_3 ...) any_2))
   (λ (x_2 ... x_1 x_3 ...) any_2)
   (side-condition (not (member (term x_1)
                                (term (x_2 ...)))))]
  ;; 2. general purpose capture avoiding case
  [(subst x_1 any_1 (λ (x_2 ...) any_2))
   (λ (x_new ...) 
     (subst x_1 any_1
            (subst-vars (x_2 x_new) ... 
                        any_2)))
   (where (x_new ...)
          ,(variables-not-in
            (term (x_1 any_1 any_2)) 
            (term (x_2 ...))))]
  ;; 3. replace x_1 with e_1
  [(subst x_1 any_1 x_1) any_1]
  ;; 4. x_1 and x_2 are different, so don't replace
  [(subst x_1 any_1 x_2) x_2]
  ;; the last cases cover all other expressions
  [(subst x_1 any_1 (any_2 ...))
   ((subst x_1 any_1 any_2) ...)]
  [(subst x_1 any_1 any_2) any_2])

(define-metafunction λB
  subst-vars : (x any) ... any -> any
  [(subst-vars (x_1 any_1) x_1) any_1]
  [(subst-vars (x_1 any_1) (any_2 ...)) 
   ((subst-vars (x_1 any_1) any_2) ...)]
  [(subst-vars (x_1 any_1) any_2) any_2]
  [(subst-vars (x_1 any_1) (x_2 any_2) ... any_3) 
   (subst-vars (x_1 any_1) 
               (subst-vars (x_2 any_2) ... any_3))]
  [(subst-vars any) any])


(define reduce
  (reduction-relation
   λB
   (--> (in-hole E ((λ (x ...) e) v ...))
        (in-hole E (subst-n (x v) ... e))
        "βv")
   ;; notice all the p_2 that have to match up
   (--> (in-hole E (blob (v) 
                         ((p_1 v_1) ... (p_2 (λ (x_2 ...) e_2)) (p_3 v_3) ...)
                         
                         ((p_4 (blob (v_v) (h_v ...) (l_v ...))) ... 
                          
                          (p_2 (blob (v_b (p_2 v_5 ...)
                                          (p_rest v_rest) ...)
                                     (h ...)
                                     (l ...)))
                          
                          (p_6 b_3) ...)))
        
        (in-hole E (blob ((λ (x_2 ...) e_2) v v_5 ...)
                         
                         ((p_1 v_1) ... (p_2 (λ (x_2 ...) e_2)) (p_3 v_3) ...)
                         
                         ((p_4 (blob (v_v) (h_v ...) (l_v ...))) ... 
                          
                          (p_2 (blob (v_b (p_rest v_rest) ...)
                                     (h ...)
                                     (l ...)))
                          
                          (p_6 b_3) ...)))
        "Signal")))

(define simple-signal
  (term (blob (5) 
              (("foo" (λ (w v) (v))))
              (("foo" (blob ("_" ("foo" 10)) () ()))))))

(define once-nested
  (term (blob (15)
              (("bar" (λ (w v) (v))))
              (("bar" (blob (5) 
                            (("foo" (λ (w v) (v ("bar" w)))))
                            (("foo" (blob ("_" ("foo" 10)) () ())))))))))

(define once-nested-two-signals
  (term (blob (15)
              (("bar" (λ (w v) (v))))
              (("bar" (blob (5) 
                            (("foo" (λ (w v) (v ("bar" w) ("bar" v)))))
                            (("foo" (blob ("_" ("foo" 10)) () ())))))))))

(define once-nested-two-blobs
  (term (blob (15)
              (("bar" (λ (w v) (v))))
              (("bar" (blob (5) 
                            (("foo" (λ (w v) (v ("bar" w)))))
                            (("foo" (blob ("_" ("foo" 10)) () ())))))
               ("bar" (blob (5) 
                            (("foo" (λ (w v) (v ("bar" v)))))
                            (("foo" (blob ("_" ("foo" 10)) () ())))))))))

(redex-match λB (in-hole E b) simple-signal)

(traces reduce simple-signal)
(traces reduce once-nested)
(traces reduce once-nested-two-signals)
(traces reduce once-nested-two-blobs)
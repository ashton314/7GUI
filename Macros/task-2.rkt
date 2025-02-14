#! /usr/bin/env gracket
#lang racket/gui

;; a bi-directional temperature converter (Fahrenheit vs Celsius)

(require 7GUI/Macros/7guis 7GUI/Macros/7state)

(define-syntax-rule (propagate-to state f field)
  (λ (new-value-of-origin)
    (set! state (stop (f new-value-of-origin)))
    (send field set-field-background (make-object color% "white"))
    (send field set-value (~r state #:precision 4))))

(define-state *C 0  (propagate-to *F (λ (c) (+ (* c 9/5) 32)) F-field))
(define-state *F 32 (propagate-to *C (λ (f) (* (- f 32) 5/9)) C-field))

(define (string->number* str)
  (define n (string->number str))
  (values n (and n (string-ref str (- (string-length str) 1)))))

(define flow
  (with (values field:num last) #:post string->number*
        (send self set-field-background (make-object color% "white"))
        (cond
          [(and field:num (rational? field:num)) (* #i1.0 field:num)]
          [else (send self set-field-background (make-object color% "red")) none])))

(define temp-field% (class text-field% (super-new [min-width 200])))
    
(gui "Temperature Converter" 
     ((#:id F-field temp-field% #:change *F flow [init-value "32"][label "fahrenheit:"])
      (#:id C-field temp-field% #:change *C flow [init-value "0"][label "celsius:"])))

#! /usr/bin/env gracket
#lang at-exp racket/gui

;; a timer that permits the continuous setting of a new interval, plus
;; a gauge and a text field that display the fraction of the elapsed time
;; a reset button that sends the elapsed time back to 0

(require 7GUI/Macros/7guis)

(define INTERVAL 100)

(define (duration-cb . x)
  (if (>= *elapsed *duration)
      (set! *elapsed *duration) ;; to trigger the *elapsed callback for redraw
      (set! *elapsed (+ *elapsed 1))))
(define timer (new timer% [notify-callback duration-cb]))

(define (elapsed-cb . x)
  (send timer start INTERVAL)
  (send text set-value (format "elapsed ~a" *elapsed))
  (define r (if (zero? *duration) 0 (quotient (* 100 *elapsed) *duration)))
  (send elapsed set-value r))

{define-state *elapsed 0 elapsed-cb}    ;; INTERVAL/1000 ms accumulated elapsed time
[define-state *duration 0 duration-cb]  ;; INTERVAL/1000 ms set duration interval 
(define set-duration (with nu (if (= nu *duration) none [begin (send timer stop) nu])))

(gui "Timer"
     (#:id elapsed gauge% [label "elapsed"][enabled #f][range 100])
     (#:id text text-field% [init-value "0"][label ""])
     (slider% #:change *duration set-duration [label "duration"][min-value 0][max-value 100])
     (button% #:change *elapsed (just (λ _ (send timer stop) (begin0 0 (duration-cb)))) [label "reset"]))

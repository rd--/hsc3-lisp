; hsc3-lisp
; ---------

; primitives are: λ, macro, set!, if, quote, fork, cons

; Emacs
; -----

; rsc3-mode can be used, type:
;
; (setq rsc3-interpreter (list "hsc3-lisp"))
;
; C-\    = lambda
; M-\    = λ
; C-cC-a = play graph
; C-cC-g = draw graph
; C-cC-k = reset scsynth

; Lambda
; ------

; Functions and procedures are of the form λ α → β.

((λ n ((* n) n)) 3) ; 9

; Lambda is not a value

λ ; error: envLookup: no key: λ

+ ; (λ a (λ b ...)))
(+ 1) ; (λ b ...))
((+ 1) 2) ; 3

; The evaluator allows two notational simplifications.
; The form (f p q) is read as ((f p) q) and so on.
; The form (f) is read as (f nil).

(+ 1 2) ; 3
((λ _ 1)) ; 1
((if #f + *) 3 4) ; 12

; Single argument λ is against the grain of traditional variadic notation.

(+ 1 2 3) ; error: (3 3)

; R4RS

((lambda (x) (+ x x)) 4) ; 8
(define reverse-subtract (lambda (x y) (- y x))) ; nil
(reverse-subtract 7 10) ; 3
(define add4 (let ((x 4)) (lambda (y) (+ x y)))) ; nil
(add4 6) ; 10

; Cons
; ----

; The cons cell is the primitive composite value.

(cons 1 2) ; (cons 1 2)

; cons cell elements are accessed using car and cdr.

(car (cons 1 2)) ; 1
(cdr (cons 1 2)) ; 2

; Predicates are:

(pair? (cons 1 2)) ; #t=1
(list? (cons 1 2)) ; #f=0
(null? (cons 1 2)) ; #f=0
(null? nil) ; #t=1
(null? '()) ; #t=1

; List
; ----

(list 1 2 3) ; (1 2 3)
(take 2 (list 1 2 3)) ; (1 2)
(list-ref (list 1 2 3) 1) ; 2 ; zero-indexed

; Quote
; -----

; quote protects an s-expression from expand and eval.

(quote a) ; a
(quote (+ 1 2)) ; (+ 1 2)

; 'x is (quote x)
'a ; a
'() ; nil
'(+ 1 2) ; (+ 1 2)
'(quote a) ; (quote a)
''a ; (quote a)

; constants
'"abc" ; "abc"
"abc" ; "abc"
'145932 ; 145932
145932 ; 145932
'#t ; 1
#t ; 1

; eval is unquote.

(eval (quote (+ 1 2))) ; 3

; Macros
; ------

; Macros are programs that re-write s-expression programs.

((λ exp (cons '- (cdr exp))) '(+ 1 2)) ; (- 1 2)

; The macro form takes an s-expression re-writing program.
; Macros are expanded not applied.

((macro (λ exp (cons '- (cdr exp)))) + 1 2) ; error

; Macros may expand to macros.

b ; error: env-lookup
(set! a (macro (λ exp (list 'set! 'b (car exp))))) ; nil
a ; Macro: (λ exp ...)
(a 5) ; nil
b ; 5

; Expand expands a form where the left hand side (lhs) is a macro.

(expand '(a 5)) ; (set! b 5)

; define, lambda, let, and, or, cond, begin, when, and list are all macros.

; Assignments & mutation
; ----------------------

; set! is the primitive environment editor.
; set! creates a new entry at the top-level environment if the variable is not otherwise located.

(define x 2) ; nil
(+ x 1) ; 3
(set! x 4) ; nil
(+ x 1) ; 5
(set! a nil) ; nil
a ; nil
(set! b (λ _ a)) ; nil
(b) ; nil
(set! a 'a) ; nil
(b) ; a

; Conditionals
; ------------

; if then else is the primitive conditional.
; The only false value is #f, all other values are #t.

(if #t 'a 'b) ; a
(if #f (print 'a) (print 'b)) ; prints b result=nil
(if 'false 'true 'false) ; true
(if (> 3 2) 'yes 'no) ; yes
(if (> 2 3) 'yes 'no) ; no
(if (> 3 2) (- 3 2) (+ 3 2)) ; 1

; if requires both true and false branches, see when for an alternate.

(if #t 'true) ; error

; Cond
; ----

(cond-rw (cdr '(cond))) ; nil
(cond-rw (cdr '(cond (a b)))) ; (if a b nil)
(cond-rw (cdr '(cond (a b) (c d)))) ; (if a b (if c d nil))
(cond-rw (cdr '(cond (a b) (c d) (else e)))) ; (if a b (if c d e))
(cond-rw (cdr '(cond ((> x y) 'gt) ((< x y) 'lt) (else 'eq)))) ; (if (> x y) ...)

(cond ((> 3 2) 'greater) ((< 3 2) 'less)) ; greater
(cond ((> 3 3) 'greater) ((< 3 3) 'less) (else 'equal)) ; equal

; Evaluation
; ----------

(eval 1) ; 1
(eval (eval 1)) ; 1

(1) ; error: apply: invalid lhs

; Variadic Expressions
; --------------------

; Macros can implement variable argument functions.

list ; Macro: (λ exp ...)
(list) ; nil
(list 1 2 3) ; (1 2 3)

; The standard macros also define the associated re-writer.

list-rw ; (λ exp ...)
(list-rw (cdr '(list))) ; nil
(list-rw (cdr '(list 1 2 3))) ; (cons 1 (cons 2 (cons 3 nil)))

; Scheme
; ------

(map (+ 1) (list 1 2 3)) ; (2 3 4)
(map (compose (+ 1) (* 2)) (list 1 2 3)) ; (3 5 7)
(map (compose (/ 2) (+ 3)) (list 1 2 3)) ; (0.5 0.4 0.33333) ; (1/2 2/5 1/3)
(map (const 3) (list 1 2 3)) ; (3 3 3)
(cons (- 1 2) ((flip -) 1 2)) ; (cons -1 1)
(id 1) ; 1

(procedure? +) ; #t

; There is a macro, lambda, that approximates the scheme form.

(lambda-rw (cdr '(lambda () x))) ; (λ _ x)
(lambda-rw (cdr '(lambda (x) x))) ; (λ x x)
(lambda-rw (cdr '(lambda (x y) (cons x y)))) ; (λ x (λ y (cons x y)))
(lambda-rw (cdr '(lambda (x y z) (list x y z)))) ; (λ x (λ y (λ z (list x y z))))

((lambda () 1) nil) ; 1
((lambda (n) (* n n)) 3) ; 9
((lambda (x y z) (+ x (+ y ((lambda (n) (* n n)) z)))) 1 2 3) ; 12

; begin cannot be elided.

((lambda (p q) (display p) (print q))) ; error: "lambda: not unary?"
((lambda (p q) (begin (display p) (print q))) 1 2) ; prints 12 ; result=nil

; nil
; ---

nil ; nil
(null? nil) ; #t=1

; Eq
; --

(equal? 'a 'a) ; #t=1
(equal? "b" "b") ; #t=1
(= 5 5) ; #t=1

; Ord
; ---

(< 0 1) ; #t=1
(> 0 1) ; #f=0
(min 1 2) ; 1
(max 1 2) ; 2
(compare 1 2) ; lt
(compare 2 1) ; gt
(compare 1 1) ; eq

; Sequencing & begin
; ------------------

(begin-rw (cdr '(begin))) ; nil
(begin-rw (cdr '(begin (print 1)))) ; ((λ _ (print 1)) nil)
(begin-rw (cdr '(begin (print 1) (print 2)))) ; ((λ _ (print 2)) ((λ _ (print 1)) nil))

(begin (print 1) (print 2) (print 3)) ; prints 1 2 3 ; result=nil
((λ _ (print 3)) ((λ _ (print 2)) ((λ _ (print 1)) nil))) ; prints 1 2 3 ; result=nil

((λ x (begin (display x) (set! x 5) (print x))) 0) ; prints 05

(define x 0) ; nil
(begin (set! x 5) (+ x 1)) ; 6
(begin (display "4 plus 1 equals ") (display (+ 4 1))) ; prints 4 plus 1 equals 5

; Define
; ------

(define x 28) ; nil
x ; 28

(define-rw (cdr '(define one 1))) ; (set! one 1)
(define one 1) ; nil
one ; 1

(define sq (λ n ((* n) n))) ; nil
(sq 5) ; 25

(define sum-sq (lambda (p q) (+ (sq p) (sq q)))) ; nil
(sum-sq 7 9) ; 130

not-defined ; error
((lambda (_) (define not-defined 1)) nil) ; nil
not-defined ; 1

; Let Binding
; -----------

(let-rw (cdr '(let () 1))) ; 1
(let-rw (cdr '(let ((a 5)) (+ a 1)))) ; ((λ a (+ a 1)) 5)
(let-rw (cdr '(let ((a 5) (b 6)) (+ a b)))) ; ((λ a ((λ b (+ a b)) 6)) 5)

(let ((a 5)) a) ; 5
(let ((a 5) (b 6)) (cons a b)) ; (cons 5 6)
(let ((a 5) (b (+ 2 3))) (* a b)) ; 25
(let ((a 5) (b (+ a 3))) (* a b)) ; 40

(let ((set! 0) (set! 1)) set!) ; 1
set! ; error

(let ((x 2) (y 3)) (* x y)) ; 6

; Let is unary

(let ((a 1)) (display a) (newline)) ; error
(let ((a 1)) (begin (display a) (newline))) ; 1\n

; Let is schemes let*, below z is bound to 7 + 3 in 7 * 10, not 2 + 3 in 7 * 5

(let ((x 2) (y 3)) (let ((x 7) (z (+ x y))) (* z x))) ; 70 (not 35)

; Recursive let
; -------------

(letrec-rw (cdr '(letrec ((a 5)) a))) ; (let ((a undefined)) (begin (set! a 5) a))

(define add-count
  (lambda (l)
    (letrec ((f (lambda (n l) (if (null? l) '() (cons (cons n (car l)) (f (+ n 1) (cdr l)))))))
      (f 0 l))))

(add-count (list 'a 'b 'c)) ; ((cons 0 a) (cons 1 b) (cons 2 c))

(letrec ((even? (lambda (n) (if (== n 0) #t (odd? (- n 1)))))
         (odd? (lambda (n) (if (== n 0) #f (even? (- n 1))))))
  (even? 88)) ; #t=1

; Logic
; -----

(not #t) ; #f=0
(not #f) ; #t=1
(not 'sym) ; #f=0
(not 3) ; #f=0
(not (list 3)) ; #f=0
(not '()) ; #f=0
(not (list)) ; #f=0
(not 'nil) ; #f=0

(and-rw (cdr '(and p q))) ; (if p q 0)
(list (and #t #t) (and #t #f) (and #f #t) (and #f #f)) ; (#t=1 #f=0 #f=0 #f=0)
(and (= 2 2) (> 2 1)) ; #t=1
(and (= 2 2) (< 2 1)) ; #f=0

(or-rw (cdr '(or p q))) ; (if p #t q)
(list (or #t #t) (or #t #f) (or #f #t) (or #f #f)) ; (#t=1 #t=1 #t=1 #f=0)
(or (= 2 2) (> 2 1)) ; #t=1
(or (= 2 2) (< 2 1)) ; #t=1
(or #f #f) ; #f=0

; and and or are binary

(and 'x 'x 'x) ; error
(or 'x 'x 'x) ; error

(when-rw (cdr '(when a b))) ; (if a b nil)
(when #t (print 'true)) ; prints true
(when #f (print 'false)) ; nil

(when ((lambda (_) #t) nil) (print 'true)) ; prints true
(when ((lambda (_) #f) nil) (print 'false)) ; nil

; Mathematics
; -----------

; Binary operator UGens are optimising.

(Add 1 2) ; 3

; Symbolic aliases are given.

(+ 1 2) ; 3

; Constants are numbers.

(number? 1) ; #t=1
(number? 'one) ; #f=0
(number? (SinOsc 5 0)) ; #f=0

; Random
; ------

(random-float-uniform 0 1) ; random floating point number in (0,1)
(random-int-uniform 0 3) ; random integer in (0,2)

; Time
; ----

(begin (print 'before) (threadSleep 1) (print 'after))

(utcr) ; <real>

(let ((t (utcr)))
  (begin
    (print 'before)
    (pauseThreadUntil (+ t 1))
    (print 'after)))

(define randomSine (Mul (SinOsc (Rand 220 440) 9) 0.01))
(audition randomSine)
(deltaTimeRescheduler (lambda (t) (begin (audition (Out 0 randomSine)) 1)) (utcr))

; IO
; --

newline-char ; 10
(write-char newline-char) ; prints newline ; \n
(newline) ; prints newline ; \n
(print 1) ; prints 1 and newline
(print (+ 1 2)) ; prints 3 and newline
(begin (display 1) (print 2)) ; prints 12 and newline
(define three (begin (display* 1) (print 2) 3)) ; 1 2 nil
three ; 3
(display "text") ; prints "text" ; ought not to print quotes

; Strings
; -------

"string" ; "string"
(string? "string") ; #t

; Load
; ----

(load "/home/rohan/sw/hsc3-lisp/scm/stdlib.scm")

; Floating Point
; --------------

(map Sin (enumFromThenTo 0 0.05 pi))

; SICP
; ----

(define square (lambda (n) (* n n))) ; nil

(define f
  (lambda (x y)
    ((lambda (a b) (+ (+ (* x (square a)) (* y b)) (* a b)))
     (+ 1 (* x y))
     (- 1 y))))

(f 7 9) ; 28088

; UGen
; ----

(reset nil)
(reset)
(draw (Mul (SinOsc 440 0) 0.1))
(draw (Mul (SinOsc (MouseX 440 880 0 0.1) 0) 0.1))
(draw (Mul (HPZ1 (WhiteNoise)) 0.1))
(displayServerStatus nil)
(audition (Out 0 (Mul (SinOsc 440 0) 0.1)))

; Case Sensitivity
; ----------------

(audition (Out 0 (Mul (SinOsc 440 0) 0.1)))

; UID
; ---

(set! uid 0) ; nil
(map incr-uid '(1 1 1)) ; (1 2 3)
(unique-uid) ; 4

; Concurrency
; -----------

(begin
  (fork (begin (print 'a) (thread-sleep 4) (print 'c)))
  (thread-sleep 2)
  (print' b))

; After a thread is begun, it runs until it completes.

; Gensym
; ------

(list (gensym) (gensym))

; Derived cons
; ------------

; Cons need not be primitive, it can be in terms of λ.

(define kons (λ x (λ y (λ m (m x y)))))
(define kar (λ z (z (λ p (λ q p)))))
(define kdr (λ z (z (λ p (λ q q)))))

(kons 1 2) ; (λ m (m x y))
(kar (kons 1 2)) ; 1
(kdr (kons 1 2)) ; 2

; Y
; -

(define length*
  ((λ h (h h))
   (λ g (λ l (if (null? l) 0 ((+ 1) ((g g) (cdr l))))))))

(length* (list 1 3 5 7 9)) ; 5

(define y (λ w ((λ f (f f)) (λ f (w (λ x ((f f) x)))))))

(define length** (y (λ f (λ l (if (null? l) 0 (+ 1 (f (cdr l))))))))

(length** (list 1 3 5 7 9)) ; 5

(define maximum*
  (y (λ f (λ l (cond ((null? l) -inf)
                     ((> (car l) (f (cdr l))) (car l))
                     (else (f (cdr l))))))))

(maximum* (list 1 5 9 7 3)) ; 9
(maximum* (list -5 -7 -3)) ; -3

; Factorial
; ---------

; https://oeis.org/A000142

(define factorial (lambda (x) (if (== x 0) 1 (* x (factorial (- x 1))))))
(map factorial (list 0 1 2 3 4 5 6 7 8 9 10)) ; (1 1 2 6 24 120 720 5040 40320 362880 3628800)

; Fibonacci
; ---------

; https://oeis.org/A000045

(define fib (lambda (x) (if (<= x 1) 1 (+ (fib (- x 1)) (fib (- x 2))))))
(map fib (enumFromTo 0 19)) ; (1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765)

; Interpreter
; -----------

(env-print)

; Vector
; ------

; vector is not implemented

(vector 1 2 3) ; error
#(1 2 3) ; error

; Case
; ----

; case is not implemented

(case (* 2 3) ((2 3 5 7) 'prime) ((1 4 6 8 9) 'composite)) ; error

; Do
; --

; do is not implemented

(let ((x '(1 3 5 7 9)))
  (do ((x x (cdr x))
       (sum 0 (+ sum (car x))))
      ((null? x) sum))) ; 25

; Boolean
; -------

; boolean? is not implemented

(boolean? #f) ; #t
(boolean? 0) ; #f
(boolean? '()) ; #f

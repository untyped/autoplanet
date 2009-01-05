#!/usr/local/plt/bin/mzscheme
#lang scheme/base

(require scheme/match
         scheme/pretty
         planet/util
         srfi/1/list
         srfi/13/string
         srfi/26/cut)

; Regular expressions --------------------------

(define owner-regexp #rx"^[a-z]+$")
(define package-regexp #rx"^[a-z-]+[.]plt$")
(define major-regexp #rx"^[0-9]+$")
(define minor-regexp #rx"^[0-9]+$")

; Utility procedures ---------------------------

;; system/output : string string ... -> string
;;
;; Executes a shell command and returns the content of standard out.
;;
;; Raises exn:fail if the command had a non-zero exit status.
;(define (system/output cmd . args)
;  (define output (open-output-string))
;  (parameterize ([current-output-port output])
;    (if (apply system* cmd args)
;        (begin0 (get-output-string output)
;                (close-output-port output))
;        (begin (close-output-port output)
;               (error "Command failed" cmd args)))))

;; accumulate-directories : complete-path (listof string) integer -> (list-of (listof string))
(define (accumulate-directories root relative depth)
  (define current (apply build-path root relative))
  (cond [(not (directory-exists? current))
         (error "Path is not a directory" current)]
        [(zero? depth)
         (list relative)]
        [else (fold (match-lambda*
                      [(list (app path->string path) accum)
                       `(,@accum ,@(accumulate-directories root `(,@relative ,path) (sub1 depth)))])
                    null      
                    (directory-list current))]))

;; directory->add-arguments : path (list string string string string) -> (list path string string null integer integer)
(define directory->add-arguments
  (match-lambda* 
    [(list root (list owner package major minor))
     (cond [(not (regexp-match owner-regexp owner))
            (error "Bad owner name in directory" owner package major minor)]
           [(not (regexp-match package-regexp package))
            (error "Bad package name in directory" owner package major minor)]
           [(not (regexp-match major-regexp major))
            (error "Bad major version number in directory" owner package major minor)]
           [(not (regexp-match minor-regexp minor))
            (error "Bad minor version number in directory" owner package major minor)]
           [else (list owner
                       package
                       (string->number major)
                       (string->number minor)
                       (build-path root owner package major minor))])]))

;; hard-link-spec->remove-arguments : (list path string string null integer integer) -> (list string string integer integer)
(define hard-link-spec->remove-arguments
  (match-lambda
    [(list _ owner package _ major minor)
     (list owner package major minor)]))

;; string string integer integer -> void
(define (remove-hard-link* . args)
  (with-handlers ([exn? void])
    (apply remove-hard-link args)))

; Main -----------------------------------------

; argv : (vectorof string)
(define argv
  (current-command-line-arguments))

; root : complete-path
(define root
  (cond [(not (zero? (vector-length argv)))
         (path->complete-path (build-path (vector-ref argv 0)))]
        [(getenv "AUTOPLANET")
         (path->complete-path (build-path (getenv "AUTOPLANET")))]
        [else (error "Please specify the root directory you wish to scan.")]))

(unless (directory-exists? root)
  (error "The root you specified is not a directory:" (path->string root)))

;; remove-arguments : (listof (list string string integer integer))
(define remove-arguments
  (map hard-link-spec->remove-arguments
       (get-hard-linked-packages)))

;; add-arguments : (listof (list string string integer integer path))
(define add-arguments
  (map (cut directory->add-arguments root <>)
       (accumulate-directories root null 4)))

(printf "===== AUTOPLANET =====~n")

(printf "~nThe following development links will be removed:~n")
(for-each (cut printf "    ~s~n" <>) remove-arguments)

(printf "~nThe following development links will be added:~n")
(for-each (cut printf "    ~s~n" <>) add-arguments)

(printf "~nProceed [y/n]? ")

(if (member (read-line) '("y" "yes" "Y" "YES" "Yes"))
    (begin (for-each (cut apply remove-hard-link* <>) remove-arguments)
           (for-each (cut apply add-hard-link <>) add-arguments)
           (printf "Done~n"))
    (begin (printf "Cancelled~n")))

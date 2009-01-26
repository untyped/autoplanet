#!/usr/local/plt/bin/mzscheme
#lang scheme/base

(require scheme/cmdline
         scheme/match
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

; complete-path (listof string) integer -> (list-of (listof string))
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

; path (list string string string string) -> (list path string string null integer integer)
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

; (list path string string null integer integer) -> (list string string integer integer)
(define hard-link-spec->remove-arguments
  (match-lambda
    [(list _ owner package _ major minor)
     (list owner package major minor)]))

; string string integer integer -> void
(define (remove-hard-link* . args)
  (with-handlers ([exn? void])
    (apply remove-hard-link args)))

; Main -----------------------------------------

(let ([root (or (getenv "AUTOPLANET") #f)] ; (U complete-path #f)
      [interactive? #f] ; boolean
      [verbose? #f]) ; boolean

  (command-line 
   #:program "autoplanet"
   #:once-each
   [("-i" "--interactive") 
    "Run in interactive mode."
    (set! interactive? #t)
    (set! verbose? #t)]
   [("-v" "--verbose")
    "Run in verbose mode."
    (set! verbose? #t)]
   [("-d" "--directory")
    dir
    "Specify source directory (defaults to $AUTOPLANET)."
    (set! root (path->complete-path (build-path dir)))])
  
  (cond [(not root)                     (error "Please specify a source directory, either on the command line or using $AUTOPLANET.")]
        [(not (directory-exists? root)) (error "Source directory does not exist:" (path->string root))])
  
  (let ([remove-arguments (map hard-link-spec->remove-arguments       ; (listof (list string string integer integer))
                               (get-hard-linked-packages))]
        [add-arguments    (map (cut directory->add-arguments root <>) ; (listof (list string string integer integer path))
                               (accumulate-directories root null 4))])

    (when verbose?
      (printf "===== AUTOPLANET =====~n")
      (printf "~nThe following development links will be removed:~n")
      (for-each (cut printf "    ~s~n" <>) remove-arguments)
      (printf "~nThe following development links will be added:~n")
      (for-each (cut printf "    ~s~n" <>) add-arguments)
      (printf "~n"))

    (if (or (not interactive?)
            (begin (printf "Proceed [y/n]? ")
                   (member (read-line) '("y" "yes" "Y" "YES" "Yes"))))
        (begin (for-each (cut apply remove-hard-link* <>) remove-arguments)
               (for-each (cut apply add-hard-link <>) add-arguments)
               (when verbose?
                 (printf "Done~n")))
        (begin (printf "Cancelled~n")))))

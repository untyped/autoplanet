#lang scheme/base

(require (for-syntax scheme/base)
         net/url
         scheme/file
         scheme/runtime-path
         scheme/system
         "main.ss"
         "test-base.ss")

; Test data --------------------------------------

(define-runtime-path temp-dir     "autoplanet-unit-test-temp")
(define-runtime-path script-file "autoplanet-unit-test-script")

; path string -> void
(define (write-file path contents)
  (when (file-exists? path)
    (delete-file path))
  (with-output-to-file path
    (lambda ()
      (display contents))))

; path string -> boolean
(define (run-script path contents)
  (write-file path contents)
  (dynamic-wind
   (lambda ()
     (void))
   (lambda ()
     (system (format "mzscheme \"~a\"" (path->string script-file))))
   (lambda ()
     (delete-file script-file))))

; Tests ------------------------------------------

(define main-tests
  (test-suite "main.ss"
    
    #:before
    (lambda ()
      (remove-hard-links)
      (when (directory-exists? temp-dir)
        (delete-directory/files temp-dir)))
    
    (test-case "install-local"
      (parameterize ([autoplanet-root temp-dir])
        (check-false (directory-exists? temp-dir))
        (make-directory temp-dir)
        (write-file (build-path temp-dir "main.ss")
                    #<<ENDSCRIPT
#lang scheme
(define x 123)
(provide x)
ENDSCRIPT
                    )
        (install-local "fake-author" "package-from-local-filesystem.plt" 1 0 temp-dir)
        ; Check the package with a require statement:
        (check-true (run-script script-file #<<ENDSCRIPT
#lang scheme
(require (planet fake-author/package-from-local-filesystem:1:0))
(printf "install-local seems to work: ~a~n" x)
ENDSCRIPT
                                ))
        (remove-hard-link "fake-author" "package-from-local-filesystem.plt" 1 0)
        (delete-directory/files temp-dir)))
    
    (test-case "install-svn"
      (parameterize ([autoplanet-root temp-dir])
        (check-false (directory-exists? temp-dir))
        (install-svn "fake-author" "package-from-svn.plt" 1 0 "http://svn.untyped.com/diff/trunk/src")
        (check-true (directory-exists? temp-dir))
        (check-true (directory-exists? (build-path temp-dir "svn" "http_svn.untyped.com_diff_trunk_src_head")))
        (check-true (run-script script-file 
                                #<<ENDSTR
#lang scheme
(require (planet fake-author/package-from-svn:1:0))
(printf "install-svn seems to work: ~a~n" make-lcs-matrix)
ENDSTR
                                ))
        (remove-hard-link "fake-author" "package-from-svn.plt" 1 0)
        (delete-directory/files temp-dir)))))

; Provide statements -----------------------------

(provide main-tests)
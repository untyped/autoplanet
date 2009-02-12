#lang scheme/base

(require (for-syntax scheme/base)
         net/url
         scheme/file
         scheme/runtime-path
         "svn.ss"
         "test-base.ss")

(require/expose "svn.ss"
  (url->filename))

(define-runtime-path temp-dir
  "autoplanet-unit-test-temp")

(define svn-tests
  (test-suite "svn.ss"
    
    (test-case "svn-url?"
      (check-true (svn-url? "http://www.example.com"))
      (check-true (svn-url? "file:/a/b/c"))
      (check-true (svn-url? "file:///a/b/c"))
      (check-true (svn-url? (string->url "http://www.example.com")))
      (check-true (svn-url? (string->url "file:/a/b/c")))
      (check-true (svn-url? (string->url "file:///a/b/c")))
      (check-false (svn-url? "dave")))
    
    (test-case "svn-revision?"
      (check-true (svn-revision? 1))
      (check-true (svn-revision? 'head))
      (check-true (svn-revision? 0))
      (check-false (svn-revision? -1))
      (check-false (svn-revision? "head"))
      (check-false (svn-revision? 'HEAD)))
    
    (test-case "url->filename"
      (check-equal? (url->filename (string->url "http://www.example.com/a/b/c"))
                    "http_www.example.com_a_b_c")
      (check-equal? (url->filename "http://www.example.com/a/b/c")
                    "http_www.example.com_a_b_c"))
    
    (test-case "svn-update"
      (check-false (directory-exists? temp-dir))
      (check-equal? (svn-update "http://svn.untyped.com/autoplanet/trunk/src" 50 (build-path temp-dir "a"))
                    (build-path temp-dir "a"))
      (check-equal? (svn-update "http://svn.untyped.com/autoplanet/trunk/src" 66 (build-path temp-dir "b"))
                    (build-path temp-dir "b"))
      (check-true (directory-exists? temp-dir))
      ; Revision 50 is an old version of autoplanet with no main.ss:
      (check-true  (file-exists? (build-path temp-dir "a" "autoplanet.ss")))
      (check-false (file-exists? (build-path temp-dir "a" "main.ss")))
      (check-false (file-exists? (build-path temp-dir "b" "autoplanet.ss")))
      (check-true  (file-exists? (build-path temp-dir "b" "main.ss")))
      (delete-directory/files temp-dir))))

; Provide statements -----------------------------

(provide svn-tests)
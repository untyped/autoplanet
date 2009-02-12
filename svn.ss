#lang scheme/base

(require net/url
         scheme/file
         scheme/system
         srfi/13
         "base.ss"
         "path.ss")

; (U string url) [(U natural 'head)] [absolute-path] -> absolute-path
(define (svn-update url [revision 'head] [path (svn-cache-path url revision)])
  (let ([url (if (string? url) url (url->string url))])
    (if (directory-exists? path)
        (let ([command-line (format "svn up -r~a ~s" revision (path->string path))])
          (unless (system command-line)
            (error "svn update failed" command-line)))
        (let ([command-line (format "svn co -r~a ~s ~s" revision url (path->string path))])
          (make-directory* path)
          (unless (system command-line)
            (error "svn checkout failed" command-line)))))
  path)

; any -> boolean
(define (svn-url? val)
  (or (and (url? val)
           (url-scheme val)
           #t)
      (and (string? val)
           (with-handlers ([exn? #f])
             (let ([url (string->url val)])
               (url-scheme url)))
           #t)))

; any -> boolean
(define (svn-revision? val)
  (or (and (integer? val)
           (>= val 0))
      (eq? val 'head)))

; (U url string) (U natural 'head) [absolute-path] -> absolute-path
(define (svn-cache-path url revision [root (autoplanet-root)])
  (build-path root "svn" (format "~a_~a" (url->filename url) revision)))

; (U url string) -> string
(define (url->filename url)
  (if (string? url)
      (url->filename (string->url url))
      (regexp-replace* #rx"/"
                       (string-join (list* (url-scheme url)
                                           (url-host url)
                                           (for/list ([path/param (in-list (url-path url))])
                                             (path/param-path path/param)))
                                    "_")
                       "_")))
  
; Provide statements -----------------------------

(provide/contract
 [svn-update     (->* (svn-url?) (svn-revision? (and/c path? absolute-path?)) (and/c path? absolute-path?))]
 [svn-url?       (-> any/c boolean?)]
 [svn-revision?  (-> any/c boolean?)]
 [svn-cache-path (->* (svn-url? svn-revision?) ((and/c path? absolute-path?)) (and/c path? absolute-path?))])
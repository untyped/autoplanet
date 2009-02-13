#lang scheme/base

(require planet/parsereq
         "base.ss"
         "path.ss"
         "svn.ss")

; -> void
(define (remove-hard-links)
  (for ([spec (get-hard-linked-packages)])
    (match spec
      [(list _ owner package _ major minor)
       (remove-hard-link owner package major minor)]))
  (void))

; string string natural natural -> void
(define (install-planet owner package major minor)
  (download/install-pkg owner package major minor)
  (void))

; string string natural natural (U path string) -> void
(define (install-local owner package major minor path)
  (let ([path (expand-user-path (if (path? path) path (string->path path)))])
    (if (absolute-path? path)
        (add-hard-link owner package major minor path)
        (error "path not absolute" path)))
  (void))

; string string natural natural string (U natural 'head) -> void
(define (install-svn owner package major minor url [revision 'head])
  (install-local owner package major minor (svn-update url revision))
  (void))

; Provide statements -----------------------------

(provide autoplanet-root
         make-autoplanet-root
         delete-autoplanet-root)

(provide/contract
 [remove-hard-links (-> void?)]
 [install-planet    (-> string? string? natural-number/c natural-number/c void?)]
 [install-local     (-> string? string? natural-number/c natural-number/c (or/c path? string?) void?)]
 [install-svn       (->* (string? string? natural-number/c natural-number/c svn-url?)
                         (svn-revision?)
                         void?)])

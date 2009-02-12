#lang scheme/base

(require scheme/file
         "base.ss")

; (parameter path)
(define autoplanet-root
  (make-parameter (build-path (current-directory) "autoplanet")))

; -> void
(define (make-autoplanet-root)
  (cond [(directory-exists? (autoplanet-root)) (void)]
        [(file-exists?      (autoplanet-root)) (error "autoplanet-path is a file" (autoplanet-root))]
        [(link-exists?      (autoplanet-root)) (error "autoplanet-path is a link" (autoplanet-root))]
        [else                                  (make-directory (autoplanet-root))]))

; -> void
(define (delete-autoplanet-root)
  (cond [(directory-exists? (autoplanet-root)) (delete-directory/files (autoplanet-root))]
        [(file-exists?      (autoplanet-root)) (error "autoplanet-path is a file" (autoplanet-root))]
        [(link-exists?      (autoplanet-root)) (error "autoplanet-path is a link" (autoplanet-root))]
        [else                                  (void)]))

; Provide statements -----------------------------

(provide/contract
 [autoplanet-root        (parameter/c (and/c path? absolute-path?))]
 [make-autoplanet-root   (-> void?)]
 [delete-autoplanet-root (-> void?)])
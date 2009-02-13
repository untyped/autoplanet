#lang setup/infotab

(define name    "Autoplanet")
(define version "1.x")
(define url     "http://svn.untyped.com/autoplanet/")

(define blurb
  '("Quick configuration of PLaneT development links."))

(define release-notes
  '((p "Fixed broken contract on " (tt "install-planet") ".")))

(define scribblings
  '(("scribblings/autoplanet.scrbl" (multi-page))))

(define primary-file 
  "main.ss")

(define categories            '(devtools))
(define required-core-version "4.0")
(define repositories          '("4.x"))

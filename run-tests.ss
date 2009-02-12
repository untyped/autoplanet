#lang scheme/base

(require "main-test.ss"
         "svn-test.ss"
         "test-base.ss")

(print-struct #t)
(error-print-width 1024)

(run-tests (test-suite "autoplanet"
             svn-tests
             main-tests))

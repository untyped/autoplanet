#lang scribble/doc

@(require "base.ss")

@title{@bold{Autoplanet:} Quick configuration of PLaneT development links}

Dave Gurnell and David Brooks

@tt{{dave, djb} at @link["http://www.untyped.com"]{@tt{untyped}}}

@italic{Autoplanet} is a wrapper for @scheme[planet/util] that lets you write
short scripts to configure PLaneT development links. These @italic{"autoplanet scripts"}
can be saved with application code to allow quick PlaneT cache reconfiguration when switching
between different versions of your code.

Here is an example:

@schemeblock[
  (require (planet untyped/autoplanet:1))

  (code:comment "Delete any existing development links:")
  (remove-hard-links)

  (code:comment "Install a published package from the PLaneT servers:")
  (install-planet "untyped" "unlib.plt" 3 12)
  
  (code:comment "Install an unpublished package in a local directory:")
  (install-local "untyped" "mirrors.plt" 2 0
                 "~/untyped/opensource/unlib/trunk/src")

  (code:comment "Install an old version of an unpublished package in SVN:")
  (make-autoplanet-root)
  (install-svn "untyped" "smoke.plt" 1 0
               "http://svn.untyped.com/smoke/trunk/src" 60)]

@defmodule[(planet untyped/autoplanet)]{

@defproc[(install-planet [owner   string?]
                         [package string?]
                         [major   integer?]
                         [minor   integer?]) void?]{
A wrapper for @scheme[download/install-pkg] in @scheme[planet/util]. Downloads and installs the specified package using the standard PLaneT mechanisms.}

@defproc[(install-local [owner   string?]
                        [package string?]
                        [major   integer?]
                        [minor   integer?] 
                        [path    (U path? string?)]) void?]{
Installs a development link for the specified package, located at @scheme[path] on the local filesystem. @scheme[path] must be absolute.}

@defproc[(install-svn [owner    string?]
                      [package  string?]
                      [major    integer?]
                      [minor    integer?] 
                      [url      (U url? string?)]
                      [revision (U integer? 'head) 'head]) void?]{
Downloads the package in the Subversion repository at the specified @scheme[url] and @scheme[revision], and installs a development link to it. The code is held locally in a subdirectory of the @scheme[autoplanet-root] directory. @scheme[autoplanet-root] must exist.}

@defparam[autoplanet-root val absolute-path?]{
The directory to use to stage SVN downloads.}

@defproc[(make-autoplanet-root) void?]{
Ensures the @scheme[autoplanet-root] directory exists. Raises an error if the path exists but is a file or a link.}

@defproc[(delete-autoplanet-root) void?]{
Deletes the @scheme[autoplanet-root] directory and all its contents. Does nothing if the path does not exist. Raises an error if the path exists and is a file or a link.}

@defproc[(remove-hard-links) void?]{
Deletes all development links. Does not delete the files that the development links were pointing to.}

} @;{end defmodule}

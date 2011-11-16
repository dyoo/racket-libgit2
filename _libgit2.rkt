#lang racket/base
(require ffi/unsafe)

;; Let's access the libgit2 libraries.
(define libgit2.so (ffi-lib "libgit2" "0"))



;; Following the guide from: http://libgit2.github.com/api.html...


;; Let's get git_repository_open and git_repository_free in place.

(define git_repository_open
  (get-ffi-obj "git_repository_open"
               libgit2.so
               (_fun ... ... -> ...)))

;; We'll be getting at the objects using get-ffi-obj, but we need
;; the proper function signatures next.

;; git_repository_open uses an output parameter for which it writes a
;; pointer.  How do we use the ffi with output parameters?


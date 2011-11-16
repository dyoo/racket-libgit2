#lang racket/base
(require ffi/unsafe)

;; Let's access the libgit2 libraries.
(define libgit2.so (ffi-lib "libgit2" "0"))



;; Following the guide from: http://libgit2.github.com/api.html...


;; Let's get git_repository_open and git_repository_free in place.
;;
;; We'll be getting at the objects using get-ffi-obj.
;;
;; We need the proper function signatures next.
;; First, let's look at the function signatures in the C API.
;;
;; http://libgit2.github.com/libgit2/#HEAD/group/repository/git_repository_open
;; http://libgit2.github.com/libgit2/#HEAD/group/repository/git_repository_free
;;
;; We now need to see how to map the types referenced in the C API to the ones
;; in Racket's FFI.  These types can be found here:
;; http://docs.racket-lang.org/foreign/types.html
;;
;; We'll touch on the first argument to get_repository_open in a moment.
;; The second argument to git_repository_open looks like a path, so let's use _path.
;; The return value of git_repository_open is an _int.
;;
;; We now have something that looks like this:
;; (define git_repository_open
;;   (get-ffi-obj "git_repository_open"
;;                 libgit2.so
;;                 (_fun ... _path -> _int)))
;;
;; Ok, let's come back to the question: what do we put in the first part?
;;
;; git_repository_open uses an output parameter for which it writes a
;; pointer.  How do we use the ffi with output parameters?
;;
(define git_repository_open
  (get-ffi-obj "git_repository_open"
               libgit2.so
               (_fun _pointer _path -> _int)))


;; We want to create storage for a single pointer.  A way to do this is with malloc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (make-git-repo-box)
  (malloc _pointer 1))

(define (git-repo-box-ref a-box)
  (ptr-ref a-box _pointer 0))

(define (git-repo-box-free a-box)
  (free a-box))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Ok, so we can create this box holding a single pointer.  Let's pass it over to
;; libgit.
(define a-repo-box (make-git-repo-box))
(void (git_repository_open a-repo-box ".git"))


;; Now, let's map git_repository_free.
(define git_repository_free
  (get-ffi-obj "git_repository_free"
               libgit2.so
               (_fun _pointer -> _void)))


;; Can we call it on our repository?
(git_repository_free (git-repo-box-ref a-repo-box))


;; Ok, good.  We should also deallocate the repo-box.
(git-repo-box-free a-repo-box)
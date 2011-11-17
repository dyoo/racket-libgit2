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



;; It's a little uncomfortable for me to treat pointers all the same.
;; They really should be typed.  Let me first create a specific pointer type
;; for git repositories.
(define-cpointer-type _git_repository)


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
  ;; Note: the box itself is garbage collected since we haven't given
  ;; the 'raw option to malloc.  So we don't have to free it explicitly.
  (malloc _git_repository 1))


(define (git-repo-box-ref a-box)
  (ptr-ref a-box _git_repository 0))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; Testing:

;; Ok, so we can create this box holding a single pointer.  Let's pass it over to
;; libgit.
(define a-repo-box (make-git-repo-box))
(printf "opening the repository\n")
(void (git_repository_open a-repo-box ".git"))


;; Now, let's map git_repository_free.
(define git_repository_free
  (get-ffi-obj "git_repository_free"
               libgit2.so
               (_fun _git_repository -> _void)))


;; Can we call it on our repository?
(git_repository_free (git-repo-box-ref a-repo-box))



;; Ok, we can open and close repositories.  We should try to do more.
;;
;; For example, let's try mapping git_repository_path.
;;
;; http://libgit2.github.com/libgit2/#HEAD/group/repository/git_repository_path
;;
;; It takes two arguments, a repository, and a git_repository_pathid.
(define git_repository_pathid (_enum '(GIT_REPO_PATH
                                       GIT_REPO_PATH_INDEX
                                       GIT_REPO_PATH_ODB
                                       GIT_REPO_PATH_WORKDIR)))

(define git_repository_path
  (get-ffi-obj "git_repository_path"
               libgit2.so
               (_fun _git_repository git_repository_pathid -> _path)))



;; Let's try using it.
(void (git_repository_open a-repo-box ".git"))
(git_repository_path (git-repo-box-ref a-repo-box) 'GIT_REPO_PATH)
(git_repository_path (git-repo-box-ref a-repo-box) 'GIT_REPO_PATH_INDEX)
(git_repository_path (git-repo-box-ref a-repo-box) 'GIT_REPO_PATH_ODB)
(git_repository_path (git-repo-box-ref a-repo-box) 'GIT_REPO_PATH_WORKDIR)

(git_repository_free (git-repo-box-ref a-repo-box))



;; By the way, let's get the version of libgit.  Although this is
;; undocumented in the public API documentation, it's something we can
;; easily bind to.  It uses three output parameters to integers to
;; represent grabbing the major, minor, and revision numbers.
(define git_libgit2_version
  (get-ffi-obj "git_libgit2_version"
               libgit2.so
               (_fun _pointer _pointer _pointer -> _void)))
;; So in order to use it, we need to malloc three blocks and pass them
;; to the function.
(define-values (major minor rev) (values (malloc _int 1)
                                         (malloc _int 1)
                                         (malloc _int 1)))
(git_libgit2_version major minor rev)
(printf "major: ~s\n" (ptr-ref major _int 0))
(printf "minor: ~s\n" (ptr-ref minor _int 0))
(printf "rev: ~s\n" (ptr-ref rev _int 0))

;; It actually makes more sense to do this one first in the tutorial.
;; It presents the need for output parameters, and it's easy to
;; exercise.

;; The higher-level API will help make this less silly to work with.



;; Let's try mapping oids.  The structure definition of an OID is:
;
;#define GIT_OID_RAWSZ 20
;struct _git_oid {
;	/** raw binary formatted id */
;	unsigned char id[GIT_OID_RAWSZ];
;};
;;

(define GIT_OID_RAWSZ 20)

;; Let's try producing _git_oid's from strings.
;; http://libgit2.github.com/libgit2/ex/HEAD/general.html#git_oid_fromstr-69
(define git_oid_fromstr
  (get-ffi-obj "git_oid_fromstr"
               libgit2.so
               (_fun (oid : (_bytes o GIT_OID_RAWSZ))
                     _string
                     -> (status : _int)
                     -> (values oid status))))
;; Here, we're defining git_oid_fromstr to return multiple values.  The _ptr allows
;; us to get output values back.  We should go back to the previous functions above
;; and use this.
(git_oid_fromstr "ce08fe4884650f067bd5703b6a59a8b3b3c99a09")
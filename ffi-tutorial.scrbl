#lang scribble/manual

@title{Reaching across the Aisle: a Foreign Function Interface tutorial}
@author+email["dyoo@hashcollision.org"]{Danny Yoo}


@section{Introduction}

Racket is not the center of the universe, and there are a lot of
useful, powerful libraries written in C.  Surprisingly enough, Racket
too can speak the lingua franca, act as a good neighbor, and reach
across the aisle to such shared libraries.

This tutorial will show how to write a binding to these libraries with
the @racketmodname[ffi/unsafe] Foreign Function Interace library.  To
make this tutorial real, we'll go through the process of writing a
binding to the @link["http://libgit2.github.com"]{libgit2} library
from scratch, which will hopefully cover the major features of the
FFI.




@;These libraries are fairly easy to reuse and typically live in
@;@link["http://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html"]{shared
@;libraries}.


@section{Getting started}

Of course, we can't bind to a library that hasn't been installed yet.
Let's try doing that first.  Here's what the process looks like under
a Unix-based system.

We can download libgit2 from its web-site and install it like 


Once the library has been installed, we want to see that the Racket
FFI can find it.
@racketblock[
(require ffi/unsafe)
(define libgit2.so (ffi-lib "libgit2" "0"))
]

Here, we use the @racket[ffi-lib] function, which takes in the name of
the library.  Libraries are usually versioned; by convention,
libraries with the same major version number provide the same
interface to clients.



@section{The beginning of a binding}

@section{Allocating memory}

@section{Binding to functions with output parameters}


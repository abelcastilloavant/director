% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/tower.R
\name{tower}
\alias{tower}
\title{Create a tower of functions.}
\usage{
tower(functions = list())
}
\arguments{
\item{functions}{list. A list of functions in the tower. The
first argument of each function must be named "object" and
each function must take a \code{...} parameter. By default
\code{list()}, which creates an identity tower that performs
no operation.}
}
\value{
An S3 "tower" object, which is a callable function
   and must be passed the \code{object} as the first argument.
   Additional arguments will be passed to the first function
   in the tower.
}
\description{
A tower is equivalent to the Ruby gem Rack's notion of middleware.
}
\details{
Imagine a function \code{f1} that, in the middle of its processing,
calls another function, \code{f2}, which in the middle of its
processing, calls another function, \code{f3}, and so on.

To construct such a structure from the list of functions
\code{list(f1, f2, ...)} we need to be able to call the
next "inner" function from the previous outer function.

This is accomplished by providing a \code{yield} keyword
which simply calls the next function in the tower.

The purpose of a tower is to modify some primary object
throughout its operation. To this end, an \code{object} keyword
will be provided to each tower function. If \code{object} is
modified prior to a \code{yield} call, the next function in
the tower will receive the modified object.

For composability, every function in a tower should have a
\code{yield} keyword. The last function in the tower will
yield to an identity function that simply returns the \code{object}.
}
\examples{
functions <- list(
  function(object, ...) {
    object <- object + 1
    object <- yield()
    object + 1
  },

  function(object, ...) {
    object <- object * 2
    yield()
  }
)

t <- tower(functions)
v <- t(1) # This is now 5, since in the tower, we increment object,
          # Multiply it by 2 in the next function, then increment it
          # again after receiving the previous function.
stopifnot(v == 5)
}


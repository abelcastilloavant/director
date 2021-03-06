context("utils")

describe("enforce_type", {
  test_that("it errors on a simple example as expected", {
    x <- 1
    expect_error(enforce_type(x, "logical", "myfunction"), "parameter must be a")
  })
})

describe("%<<% operator", {
  test_that("it errors unless objects are named", {
    expect_error(list(1) %<<% list(2))
    expect_error(list(a = 1) %<<% list(2))
    expect_error(list(1) %<<% list(a = 2))
  })

  describe("inserting into lists", {
    test_that("it can insert list elements", {
      x <- list(a = 1)
      expect_identical(x %<<% list(b = 2), list(a = 1, b = 2))
      expect_identical(x %<<% list(a = 2), list(a = 2))
    })

    test_that("it can insert environments into lists", {
      x <- list(a = 1)
      expect_identical(x %<<% list2env(list(b = 2)), list(a = 1, b = 2))
      expect_identical(x %<<% list2env(list(a = 2)), list(a = 2))
    })
  })

  describe("inserting into environments", {
    tolist <- function(x) {
      x <- as.list(x)
      x[sort(names(x))]
    }

    test_that("it can insert lists into environments", {
      x <- list2env(list(a = 1))
      expect_identical(tolist(x %<<% list(b = 2)), list(a = 1, b = 2))
      x <- list2env(list(a = 1))
      expect_identical(tolist(x %<<% list(a = 2)), list(a = 2))
    })

    test_that("it can insert environments into environments", {
      x <- list2env(list(a = 1))
      expect_identical(tolist(x %<<% list2env(list(b = 2))), list(a = 1, b = 2))
      x <- list2env(list(a = 1))
      expect_identical(tolist(x %<<% list2env(list(a = 2))), list(a = 2))
    })
  })
})

describe("sized_queue", {
  test_that("it handles queue overflow correctly", {
    q <- sized_queue(size = 2)
    q$push(1); expect_equal(lapply(1:2, q$get), list(1, NULL))
    q$push(2); expect_equal(lapply(1:2, q$get), list(2, 1))
    q$push(3); expect_equal(lapply(1:3, q$get), list(3, 2, NULL))
  })

  test_that("it can record the lnegth", {
    q <- sized_queue(size = 2)
    expect_equal(q$length(), 0)
    q$push(1); expect_equal(q$length(), 1)
    q$push(1); expect_equal(q$length(), 2)
    q$push(1); expect_equal(q$length(), 2)
  })
})

describe("get_helpers", {
  test_that("within an idempotent directory, gets helpers", {
    within_file_structure(list(a = list("a.R", "b.R", c = list("d.R"), d = list("d.R", "e.R"))), {
      expect_equal(get_helpers(file.path(tempdir, "a")), "b.R")
      expect_equal(sort(get_helpers(file.path(tempdir, "a"), leave_idempotent = TRUE)), c("a.R", "b.R"))
    })
  })
})

describe("resource_name", {
  test_that("it can turn a non-idempotent resource into a resource name", {
    expect_equal(resource_name("foo.R"), "foo")
    expect_equal(resource_name("foo.r"), "foo")
    expect_equal(resource_name("foo"), "foo")
  })

  test_that("it can turn a idempotent resource into a resource name", {
    expect_equal(resource_name("foo/foo.R"), "foo")
    expect_equal(resource_name("foo/foo.r"), "foo")
    expect_equal(resource_name("foo/foo"), "foo")
  })
})

describe("simple_cache", {
  test_that("it can determine whether an element exists", {
    cache <- simple_cache()
    cache$set("foo", "bar")
    expect_true(cache$exists("foo"))
    expect_false(cache$exists("bar"))
  })
})

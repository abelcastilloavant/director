context('director$find method')
require(testthatsomemore)

describe("invalid inputs", {
  test_that("it errors when we pass a non-character base", {
    expect_error(director(tempdir())$find(base = NULL), "parameter must be a")
  })
})

test_that('it correctly finds no files in an empty directory', {
  within_file_structure(list(), { d <- director(tempdir)
    expect_equal(0, length(d$find('')), info = 'No files should have been found.')
  })
})

test_that('it correctly finds a simple file in the root with the exact method', {
  within_file_structure(list('hello.R'), { d <- director(tempdir)
    expect_identical('hello', d$find('hello', method = 'exact'),
                     info = 'The find method should have found the file "hello".')
  })
})

test_that('it correctly finds a simple file and not the other in the root with the partial method', {
  within_file_structure(list('hello.R', 'boo.R'), { d <- director(tempdir)
    expect_identical('hello', d$find('ell', method = 'partial'),
                     info = 'The find method should have found just the file "hello".')
  })
})

test_that('it correctly finds a simple nested file with the partial method', {
  within_file_structure(list(uno = list('dos.R')), { d <- director(tempdir)
    expect_identical('uno/dos', d$find('o/do', method = 'partial'),
                     info = 'The find method should have found the nested resource uno/dos.')
  })
})

test_that('it correctly finds a nested file using wildcard search', {
  within_file_structure(list(uno = list(dos = list(tres = list('quatro.R')))), { d <- director(tempdir)
    expect_identical('uno/dos/tres/quatro', d$find('ooeuao', method = 'wildcard'),
                     info = 'The find method should have found the nested resource uno/dos/tres/quatro.')
  })
})

test_that('it correctly does not find a nested file using wildcard search', {
  within_file_structure(list(uno = list(dos = list(tres = list('quatro.R')))), { d <- director(tempdir)
    expect_equal(0, length(d$find('ooeuaoo', method = 'wildcard')),
                 info = 'The find method should not have found the nested resource uno/dos/tres/quatro.')
  })
})

test_that('it correctly uses a base to look for an exact match', {
  within_file_structure(list(uno = list('dos.R')), { d <- director(tempdir)
    expect_identical('uno/dos', d$find('dos', base = 'uno', method = 'exact'),
      info = 'Since we are looking for dos with base uno, it should be found.')
  })
})

test_that('it correctly uses a base to look for a partial match', {
  within_file_structure(list(uno = list(dos = list('tres.R'))), { d <- director(tempdir)
    expect_identical('uno/dos/tres', d$find('os/t', base = 'uno', method = 'partial'),
      info = 'Since we are looking for "os/t" with base uno, it should find uno/dos/tres.')
  })
})

test_that('it correctly uses a base to look for a wildcard match', {
  within_file_structure(list(uno = list(dos = list('tres.R'))), { d <- director(tempdir)
    expect_identical('uno/dos/tres', d$find('ots', base = 'uno', method = 'wildcard'),
      info = 'Since we are looking for "os/t" with base uno, it should find uno/dos/tres.')
  })
})

test_that('it can find idempotent resources', {
  within_file_structure(list(uno = list('uno.R')), { d <- director(tempdir)
    expect_identical('uno', d$find('uno'),
      info = 'Since we are looking for the idempotent resource "uno", it should find "uno".')
  })
})

test_that('correctly finds files ordered by modification time', {
  within_file_structure(list('hello.R', 'boo.R'), { d <- director(tempdir)
    writeLines("#", file.path(tempdir, "hello.R"))
    touch_file(file.path(tempdir, "hello.R"))
    expect_identical(c('hello', 'boo'), d$find('', by_mtime = TRUE))
  })
})

test_that('ignores modification time when by_mtime = FALSE', {
  within_file_structure(list('hello.R', 'boo.R'), { d <- director(tempdir)
    writeLines("#", file.path(tempdir, "hello.R"))
    touch_file(file.path(tempdir, "hello.R"))
    expect_identical(c('boo', 'hello'), d$find('', by_mtime = FALSE))
  })
})

test_that("it supports finding with multiple bases", {
  within_file_structure(list(uno = list('foo.R'), dos = list('foo.R')), { d <- director(tempdir)
    expect_identical(d$find("foo", base = c("uno", "dos")), c("uno/foo", "dos/foo"))
  })
})

test_that("it can find files with multiple extensions", {
  within_file_structure(list(foo.sql.R = "'select * from foo'"), { d <- director(tempdir)
    expect_identical(d$find(""), "foo.sql")
  })
})

test_that("it correctly does an exact match on idempotent resources", {
  within_file_structure(list(uno = list(dos = list('dos.R'))), { d <- director(tempdir)
    expect_identical('uno/dos', d$find("uno/dos", method = "exact"),
      info = "Exact matching shoudl find uno/dos as an idempotent resource.")
  })
})

test_that("it correctly does an exact match on idempotent resources with base", {
  within_file_structure(list(uno = list(dos = list('dos.R'))), { d <- director(tempdir)
    expect_identical('uno/dos', d$find("dos", base = "uno", method = "exact"),
      info = "Exact matching shoudl find uno/dos as an idempotent resource.")
  })
})



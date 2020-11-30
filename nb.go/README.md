# `nb.go`

`nb.go` is an implementation of [`nb`](https://github.com/xwmx/nb) written in
[Go](https://golang.org/).

## Objectives

- Improved Windows support. Runnable with no dependencies on a default Windows
  install, or as close to default as possible.
- 1 to 1 feature parity with `nb`, passing the same test suite.
- Continuously usable during development, falling back to `nb` for
  functionality not yet implemented in Go.
- Automatic, zero-configuration performance improvements for `nb` when `nb.go` is installed.
- Minimal dependencies.
- Single file.

## Tests

The `nb.go` test suite consists of Go tests for internal functionality and
bats tests to verify external behavior of the executable. Tests from the
primary bats test suite are symlinked into
[nb.go/test](https://github.com/xwmx/nb/tree/master/nb.go/test)
in order to run against `nb.go`. 

---

<p align="center">
  <a href="https://github.com/xwmx/nb">github.com/xwmx/nb</a>
</p>

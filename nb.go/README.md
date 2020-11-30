# `nb.go`

`nb.go` is an implementation of `nb` written in
[Go](https://golang.org/).

## Objectives

- Improved Windows support. Runnable with no dependencies in a default windows
  install, or as close to default as possible.
- 1 to 1 feature parity with `nb`, passing the same test suite.
- Continuously usable during development, falling back to `nb` for
  functionality not yet implemented in go.
- Transparent performance improvements for `nb` when `nb.go` is installed.
- Minimal dependencies.
- Single file.

## Tests

The nb.go test suite consists of go unit tests for internal functionality and
bats tests to verify external behavior. Tests from the primary test
suite are symlinked into nb.go/test in order to run against the nb.go
binary.

---

<p align="center">
  <a href="https://github.com/xwmx/nb">github.com/xwmx/nb</a>
</p>

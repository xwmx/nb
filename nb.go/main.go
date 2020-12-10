// __          _
// \ \   _ __ | |__       __ _  ___
//  \ \ | '_ \| '_ \     / _` |/ _ \
//  / / | | | | |_) | _ | (_| | (_) |
// /_/  |_| |_|_.__/ (_) \__, |\___/
//                       |___/
//
// [nb.go] An implementation of `nb` in go.
//
// ❯ https://github.com/xwmx/nb
// ❯ https://xwmx.github.io/nb
//
// Copyright (c) 2020-present William Melody ┯ hi@williammelody.com
//                                           ┕ https://www.williammelody.com
//
// AGPLv3
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// revive:disable:error-strings Errors should match existing `nb` formatting.

package main

import (
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"syscall"

	"golang.org/x/sys/unix"
)

type config struct {
	colorEnabled       bool
	currentWorkingDir  string
	editor             string
	gitEnabled         bool
	globalNotebookPath string
	localNotebookPath  string
	nbAutoSync         bool
	nbColorPrimary     int
	nbColorSecondary   int
	nbColorTheme       string
	nbColorThemes      []string
	nbDefaultExtension string
	nbDir              string
	nbEncryptionTool   string
	nbFooter           bool
	nbHeader           int
	nbLimit            int
	nbNotebookPath     string
	nbPath             string
	nbrcPath           string
	nbSyntaxTheme      string
}

// configure loads the configuration from the environment.
func configure() (config, error) {
	var err error

	cfg := config{}

	// currentWorkingDir / PWD
	//
	// The current working directory in which the program was invoked.

	if cfg.currentWorkingDir, err = os.Getwd(); err != nil {
		return cfg, err
	}

	// `nb` (.sh) path
	//
	// The path to the `nb` executable.

	if cfg.nbPath, err = exec.LookPath("nb"); err != nil {
		adjacentNbPath := filepath.Join(cfg.currentWorkingDir, "..", "nb")

		if _, err := os.Stat(adjacentNbPath); err == nil {
			cfg.nbPath = adjacentNbPath
		} else {
			return cfg, err
		}
	}

	// $NBRC_PATH
	//
	// Default: `$HOME/.nbrc`
	//
	// The location of the .nbrc configuration file.

	if cfg.nbrcPath = os.Getenv("NBRC_PATH"); cfg.nbrcPath == "" {
		if runtime.GOOS == "windows" {
			// TODO
		} else {
			cfg.nbrcPath = filepath.Join(os.Getenv("HOME"), ".nbrc")

			// TODO: Handle symlinks.
			// TODO: Source rc file.
		}
	}

	// $NB_DIR
	//
	// Default: `$HOME/.nb`
	//
	// The location of the directory that contains the notebooks.

	if cfg.nbDir = os.Getenv("NB_DIR"); cfg.nbDir == "" {
		var parentDir string

		if runtime.GOOS == "windows" {
			// TODO:
			// - Validate directory.
			// - Confirm directory locations.
			//
			// See also:
			// https://stackoverflow.com/a/49148866

			parentDir = os.Getenv("APPDATA")

			if parentDir == "" {
				parentDir = filepath.Join(
					os.Getenv("USERPROFILE"), "Application Data",
				)
			}

			cfg.nbDir = filepath.Join(parentDir, "nb")
		} else {
			cfg.nbDir = filepath.Join(os.Getenv("HOME"), ".nb")

			// https://godoc.org/golang.org/x/sys/unix#Access
			// https://stackoverflow.com/a/20026945
			if cfg.nbDir == "" || cfg.nbDir == "/" || unix.Access(cfg.nbDir, unix.W_OK) != nil {
				errorString := fmt.Sprintf(`\
NB_DIR is not valid:
  %s

Remove any NB_DIR settings in .nbrc to reset to default:
  %s

NB_DIR settings prompt:
  %s settings nb_dir`, cfg.nbDir, cfg.nbrcPath, "nb")

				return cfg, errors.New(errorString)
			}
		}
	}

	if cfg.nbDir != "" {
		os.Setenv("NB_DIR", cfg.nbDir)
	}

	// $_GIT_ENABLED
	//
	// Default: '1'
	//
	// Supported Values: '0' '1'

	if os.Getenv("_GIT_ENABLED") == "0" {
		cfg.gitEnabled = false
		os.Setenv("_GIT_ENABLED", "0")
	} else {
		cfg.gitEnabled = true
		os.Setenv("_GIT_ENABLED", "1")
	}

	if cfg.gitEnabled {
		os.Setenv("NB_DIR", cfg.nbDir)
	}

	// $NB_AUTO_SYNC
	//
	// Default: '1'
	//
	// When set to '1', each `_git checkpoint()` call will automativally run
	// `$_ME sync`. To disable this behavior, set the value to '0'.

	if os.Getenv("NB_AUTO_SYNC") == "0" {
		cfg.nbAutoSync = false
		os.Setenv("NB_AUTO_SYNC", "0")
	} else {
		cfg.nbAutoSync = true
		os.Setenv("NB_AUTO_SYNC", "1")
	}

	// $NB_DEFAULT_EXTENSION
	//
	// Default: 'md'
	//
	// Example Values: 'md' 'org'

	if cfg.nbDefaultExtension = os.Getenv("NB_DEFAULT_EXTENSION"); cfg.nbDefaultExtension == "" {
		cfg.nbDefaultExtension = "md"
	}

	os.Setenv("NB_DEFAULT_EXTENSION", cfg.nbDefaultExtension)

	// $NB_ENCRYPTION_TOOL
	//
	// Default: 'openssl'
	//
	// Supported Values: 'gpg' 'openssl'

	if cfg.nbEncryptionTool = os.Getenv("NB_ENCRYPTION_TOOL"); cfg.nbEncryptionTool == "" {
		cfg.nbEncryptionTool = "openssl"
	}

	os.Setenv("NB_ENCRYPTION_TOOL", cfg.nbEncryptionTool)

	// $NB_FOOTER
	//
	// Default: '1'
	//
	// Supported Values: '0' '1'

	if os.Getenv("NB_FOOTER") == "0" {
		cfg.nbFooter = false
		os.Setenv("NB_FOOTER", "0")
	} else {
		cfg.nbFooter = true
		os.Setenv("NB_FOOTER", "1")
	}

	// $NB_HEADER
	//
	// Default: '2'
	//
	// Supported Values: '0' '1' '2' '3'

	if cfg.nbHeader, err = strconv.Atoi(os.Getenv("NB_HEADER")); err != nil {
		cfg.nbHeader = 2
	}

	os.Setenv("NB_HEADER", strconv.Itoa(cfg.nbHeader))

	// $NB_LIMIT
	//
	// Default: '20'
	//
	// Supported Values: any positive number

	if cfg.nbLimit, err = strconv.Atoi(os.Getenv("NB_LIMIT")); err != nil {
		cfg.nbLimit = 20
	}

	os.Setenv("NB_HEADER", strconv.Itoa(cfg.nbLimit))

	// $NB_SYNTAX_THEME
	//
	// Default: 'base16'
	//
	// Supported Values: Theme names listed with `bat --list-themes`

	if cfg.nbSyntaxTheme = os.Getenv("NB_SYNTAX_THEME"); cfg.nbSyntaxTheme == "" {
		cfg.nbSyntaxTheme = "base16"
	}

	os.Setenv("NB_SYNTAX_THEME", cfg.nbSyntaxTheme)

	// Notebook Paths

	cfg = configureNotebookPaths(cfg)

	// return

	return cfg, nil
}

// configureNotebookPaths takes a configuration and returns a copy with
// notebook path fields set to values derived from the environment.
func configureNotebookPaths(cfg config) config {
	// TODO

	cfg.nbNotebookPath = filepath.Join(cfg.nbDir, "home")

	return cfg
}

// contains takes a slice of strings and a string and returns a boolean
// indicating whether the slice contains the string.
func contains(slice []string, query string) bool {
	for _, e := range slice {
		if e == query {
			return true
		}
	}
	return false
}

// run loads the configuration and environment, then runs the subcommand.
func run() (io.Reader, chan int, error) {
	var cfg config
	var err error
	var exitStatusChannel chan int
	var outputReader io.Reader

	if cfg, err = configure(); err != nil {
		return nil, nil, err
	}

	args := os.Args
	env := os.Environ()

	if len(args) > 1 && args[1] == "run" {
		outputReader, exitStatusChannel, err = runSubCmdRun(
			subCmdCall{
				args:        args[2:],
				cfg:         cfg,
				env:         env,
				inputReader: os.Stdin,
				options:     map[string]string{"execType": "forkexec"},
				// options: map[string]string{"execType": "goroutine"},
			},
		)
		if err != nil {
			return outputReader, exitStatusChannel, err
		}
	} else {
		if err := syscall.Exec(cfg.nbPath, args, env); err != nil {
			return nil, nil, err
		}
	}

	return outputReader, exitStatusChannel, nil
}

// main is the primary entry point for the program.
func main() {
	os.Exit(present(run()))
}

func pipedInputIsPresent() bool {
	// Resources:
	// https://flaviocopes.com/go-shell-pipes/
	// https://coderwall.com/p/zyxyeg/golang-having-fun-with-os-stdin-and-shell-pipes
	info, err := os.Stdin.Stat()
	if err != nil {
		panic(err)
	}

	if info.Mode()&os.ModeCharDevice != 0 || info.Size() <= 0 {
		return false
	}

	return true
}

// present prints the output to standard out or standard error and returns the
// appropriate exit code.
func present(output io.Reader, exitStatusChannel chan int, err error) int {
	exitStatus := 0

	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)

		return 1
	}

	if output != nil {
		io.Copy(os.Stdout, output)
	}

	if exitStatusChannel != nil {
		exitStatus = <-exitStatusChannel
	}

	return exitStatus
}

type subCmd struct {
	aliasFor    string
	documented  bool
	function    subCmdFunc
	name        string
	triggersGit bool
	usage       string
}

type subCmdCall struct {
	args        []string
	cfg         config
	env         []string
	inputReader io.Reader
	options     map[string]string
}

type subCmdFunc func(subCmdCall) (io.Reader, chan int, error)

var subCmdList = subCmd{
	documented:  true,
	function:    runSubCmdList,
	name:        "list",
	triggersGit: true,
}

// runSubCmdList runs the `list` subcommand.
func runSubCmdList(call subCmdCall) (io.Reader, chan int, error) {
	return nil, nil, nil
}

var subCmdLs = subCmd{
	documented:  true,
	function:    runSubCmdLs,
	name:        "ls",
	triggersGit: true,
}

// runSubCmdLs runs the `ls` subcommand.
func runSubCmdLs(call subCmdCall) (io.Reader, chan int, error) {
	return nil, nil, nil
}

var subCmdRun = subCmd{
	documented:  true,
	function:    runSubCmdRun,
	name:        "run",
	triggersGit: true,
}

// runSubCmdRun runs the `run` subcommand.
func runSubCmdRun(call subCmdCall) (io.Reader, chan int, error) {
	if len(call.args) == 0 {
		return nil, nil, errors.New("Command required.")
	}

	exitStatusChannel := make(chan int)
	exitStatus := 0

	var outputReader io.ReadCloser
	var outputWriter io.WriteCloser

	if call.options["execType"] == "forkexec" {
		pid, err := syscall.ForkExec(
			"/usr/bin/env",
			[]string{"/usr/bin/env", "bash", "-c", strings.Join(call.args, " ")},
			&syscall.ProcAttr{
				Dir:   call.cfg.nbNotebookPath,
				Env:   call.env,
				Files: []uintptr{os.Stdin.Fd(), os.Stdout.Fd(), os.Stderr.Fd()},
			},
		)

		if err != nil {
			return nil, nil, err
		}

		proc, err := os.FindProcess(pid)
		if err != nil {
			return nil, nil, err
		}

		state, err := proc.Wait()
		if err != nil {
			return nil, nil, err
		}

		if status, ok := state.Sys().(syscall.WaitStatus); ok {
			exitStatus = status.ExitStatus()
		}

		go func() {
			exitStatusChannel <- exitStatus
		}()
	} else {
		outputReader, outputWriter = io.Pipe()

		go func() {
			cmd := exec.Command(call.args[0], call.args[1:]...)

			cmd.Dir = call.cfg.nbNotebookPath
			cmd.Stderr = os.Stderr
			cmd.Stdout = outputWriter

			cmd.Start()

			// https://stackoverflow.com/a/10385867
			if err := cmd.Wait(); err != nil {
				exitStatus = 1

				if exiterr, ok := err.(*exec.ExitError); ok {
					// The program has exited with an exit code != 0

					// This works on both Unix and Windows. Although package
					// syscall is generally platform dependent, WaitStatus is
					// defined for both Unix and Windows and in both cases has
					// an ExitStatus() method with the same signature.
					if status, ok := exiterr.Sys().(syscall.WaitStatus); ok {
						exitStatus = status.ExitStatus()
					}
				}
			}

			outputWriter.Close()

			exitStatusChannel <- exitStatus
		}()
	}

	return outputReader, exitStatusChannel, nil
}

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

	"golang.org/x/sys/unix"

	// "strings"
	"syscall"
)

type config struct {
	colorEnabled       bool
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

type subcommand struct {
	aliasedSubcommand string
	documented        bool
	name              string
	triggersGit       bool
	usage             string
}

// cmdRun runs the `run` subcommand.
func cmdRun(cfg config, input io.Reader, args []string, env []string) (io.Reader, error) {
	var arguments []string

	if len(args) < 2 {
		return nil, errors.New("Command required.")
	} else if 2 <= len(args) {
		arguments = args[2:]
	} else {
		arguments = []string{}
	}

	pipeReader, pipeWriter := io.Pipe()

	go func() {
		cmd := exec.Command(args[1], arguments...)

		cmd.Dir = cfg.nbDir
		cmd.Stderr = os.Stderr
		cmd.Stdout = pipeWriter

		cmd.Start()
		cmd.Wait()

		pipeWriter.Close()
	}()

	return pipeReader, nil
}

// configure loads the configuration from the environment.
func configure() (config, error) {
	var err error

	cfg := config{}

	// `nb` (.sh) path

	if cfg.nbPath, err = exec.LookPath("nb"); err != nil {
		return config{}, err
	}

	// $NBRC_PATH

	if cfg.nbrcPath = os.Getenv("NBRC_PATH"); cfg.nbrcPath == "" {
		if runtime.GOOS == "windows" {
			// TODO
		} else {
			cfg.nbrcPath = filepath.Join(os.Getenv("HOME"), ".nbrc")

			// TODO: Sourcing rc file.
		}
	}

	// $NB_DIR

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

	if os.Getenv("NB_AUTO_SYNC") == "0" {
		cfg.nbAutoSync = false
		os.Setenv("NB_AUTO_SYNC", "0")
	} else {
		cfg.nbAutoSync = true
		os.Setenv("NB_AUTO_SYNC", "1")
	}

	// $NB_DEFAULT_EXTENSION

	if cfg.nbDefaultExtension = os.Getenv("NB_DEFAULT_EXTENSION"); cfg.nbDefaultExtension == "" {
		cfg.nbDefaultExtension = "md"
	}

	os.Setenv("NB_DEFAULT_EXTENSION", cfg.nbDefaultExtension)

	// $NB_ENCRYPTION_TOOL

	if cfg.nbEncryptionTool = os.Getenv("NB_ENCRYPTION_TOOL"); cfg.nbEncryptionTool == "" {
		cfg.nbEncryptionTool = "openssl"
	}

	os.Setenv("NB_ENCRYPTION_TOOL", cfg.nbEncryptionTool)

	// $NB_FOOTER

	if os.Getenv("NB_FOOTER") == "0" {
		cfg.nbFooter = false
		os.Setenv("NB_FOOTER", "0")
	} else {
		cfg.nbFooter = true
		os.Setenv("NB_FOOTER", "1")
	}

	// $NB_HEADER

	if cfg.nbHeader, err = strconv.Atoi(os.Getenv("NB_HEADER")); err != nil {
		cfg.nbHeader = 2
	}

	os.Setenv("NB_HEADER", strconv.Itoa(cfg.nbHeader))

	// $NB_LIMIT

	if cfg.nbLimit, err = strconv.Atoi(os.Getenv("NB_LIMIT")); err != nil {
		cfg.nbLimit = 20
	}

	os.Setenv("NB_HEADER", strconv.Itoa(cfg.nbLimit))

	// $NB_SYNTAX_THEME

	if cfg.nbSyntaxTheme = os.Getenv("NB_SYNTAX_THEME"); cfg.nbSyntaxTheme == "" {
		cfg.nbSyntaxTheme = "base16"
	}

	os.Setenv("NB_SYNTAX_THEME", cfg.nbSyntaxTheme)

	// return

	return cfg, nil
}

// run loads the configuration and environment, then runs the subcommand.
func run() (io.Reader, error) {
	var cfg config
	var err error
	var output io.Reader

	if cfg, err = configure(); err != nil {
		return output, err
	}

	args := os.Args
	env := os.Environ()

	if len(args) > 1 && args[1] == "run" {
		if output, err = cmdRun(cfg, os.Stdin, args[1:], env); err != nil {
			return output, err
		}
	} else {
		if err := syscall.Exec(cfg.nbPath, args, env); err != nil {
			return output, err
		}
	}

	return output, nil
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
func present(output io.Reader, err error) int {
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)

		return 1
	}

	if output != nil {
		io.Copy(os.Stdout, output)
	}

	return 0
}

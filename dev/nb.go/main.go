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

package main

// revive:disable:error-strings Errors should match existing `nb` formatting.

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
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
	nbSyntaxTheme      string
}

type subcommand struct {
	name  string
	usage string
}

// cmdRun runs the `run` subcommand.
func cmdRun(cfg config, args []string, env []string) error {
	var arguments []string

	if len(args) < 2 {
		return errors.New("Command required.")
	} else if 2 <= len(args) {
		arguments = args[2:]
	} else {
		arguments = []string{}
	}

	cmd := exec.Command(args[1], arguments...)
	cmd.Dir = cfg.nbDir

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

// configure loads the configuration from the environment.
func configure() (config, error) {
	var err error

	cfg := config{}

	// `nb` (.sh) path

	if cfg.nbPath, err = exec.LookPath("nb"); err != nil {
		return config{}, err
	}

	// $NB_DIR

	if cfg.nbDir = os.Getenv("NB_DIR"); cfg.nbDir == "" {
		var parentDir string

		if runtime.GOOS == "windows" {
			parentDir = os.Getenv("APPDATA")

			if parentDir == "" {
				parentDir = filepath.Join(
					os.Getenv("USERPROFILE"), "Application Data",
				)
			}

			cfg.nbDir = filepath.Join(parentDir, "nb")
		} else {
			cfg.nbDir = filepath.Join(os.Getenv("HOME"), ".nb")
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
func run() error {
	var cfg config
	var err error

	if cfg, err = configure(); err != nil {
		return err
	}

	args := os.Args
	env := os.Environ()

	if len(args) > 1 && args[1] == "run" {
		if err := cmdRun(cfg, args[1:], env); err != nil {
			return err
		}
	} else {
		if err := syscall.Exec(cfg.nbPath, args, env); err != nil {
			return err
		}
	}

	return nil
}

// main is the primary entry point for the program.
func main() {
	os.Exit(presentError(run()))
}

// presentError translates an error into a message presnted to the user and
// returns the appropriate exit code.
func presentError(err error) int {
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		return 1
	}

	return 0
}

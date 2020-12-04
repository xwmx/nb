// revive:disable:error-strings Errors should match existing `nb` formatting.

package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

func TestConfigureSetsCurrentWorkingDir(t *testing.T) {

	pwdOutput, err := exec.Command("pwd").Output()

	if err != nil {
		t.Errorf(
			"exec.Command(\"pwd\") error = %s",
			err,
		)
	}

	pwd := string(pwdOutput)
	pwd = strings.TrimSuffix(pwd, "\n")

	expectedCfg := config{
		currentWorkingDir: pwd,
	}

	returnedCfg, err := configure()

	if err != nil {
		t.Errorf(
			"configure() error = %s",
			err,
		)
	}

	if returnedCfg.currentWorkingDir != expectedCfg.currentWorkingDir {
		t.Errorf(
			"configure() cfg.currentWorkingDir\ngot:  '%s'\nwant: '%s'",
			returnedCfg.currentWorkingDir,
			expectedCfg.currentWorkingDir,
		)
	}

	os.Setenv("NB_DIR", "")
}

func TestConfigureSetsNbDir(t *testing.T) {
	os.Setenv("NB_DIR", filepath.Join("tmp", "example-nb-dir"))

	expectedCfg := config{
		nbDir: filepath.Join("tmp", "example-nb-dir"),
	}

	returnedCfg, err := configure()

	if err != nil {
		t.Errorf(
			"configure() error = %s",
			err,
		)
	}

	if returnedCfg.nbDir != expectedCfg.nbDir {
		t.Errorf(
			"configure() cfg.nbDir\ngot:  '%s'\nwant: '%s'",
			returnedCfg.nbDir,
			expectedCfg.nbDir,
		)
	}

	os.Setenv("NB_DIR", "")
}

// revive:disable:error-strings Errors should match existing `nb` formatting.

package main

import (
	"os"
	"path/filepath"
	"testing"
)

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
			"configure() cfg.nbDir = %s; want: %s.",
			returnedCfg.nbDir,
			expectedCfg.nbDir,
		)
	}

	os.Setenv("NB_DIR", "")
}

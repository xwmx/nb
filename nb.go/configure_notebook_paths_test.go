// revive:disable:error-strings Errors should match existing `nb` formatting.

package main

import (
	"path/filepath"
	"testing"
)

func TestConfigureNotebookPathsSetsNotebookPathFields(t *testing.T) {
	originalCfg := config{
		nbDir: filepath.Join("tmp", "example-nb-dir"),
	}

	expectedPath := filepath.Join(originalCfg.nbDir, "home")

	var returnedCfg config

	returnedCfg = configureNotebookPaths(originalCfg)

	if returnedCfg.nbNotebookPath != expectedPath {
		t.Errorf(
			"configureNotebookPaths() cfg.nbNotebookPath = %s; want: %s.",
			returnedCfg.nbNotebookPath,
			expectedPath,
		)
	}
}

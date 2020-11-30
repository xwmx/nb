package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

func TestCmdRunPrintsOutput(t *testing.T) {
	// TODO: Create temp directories.
	// cfg := config{
	//   nbDir:          filepath.Join("tmp", "example-nb-dir"),
	//   nbNotebookPath: filepath.Join("tmp", "example-nb-dir", "home"),
	// }

	cfg, _ := configure()

	runCmdResponse, exitStatusChannel, err := cmdRun(
		subcommandCall{
			cfg:         cfg,
			inputReader: nil,
			args:        []string{"echo", "example output"},
			env:         os.Environ(),
			options:     map[string]string{"execType": "goroutine"},
		},
	)

	if err != nil {
		t.Errorf(
			"cmdRun() err = %s",
			err,
		)
	}

	if runCmdResponse == nil {
		t.Errorf(
			"cmdRun() 'echo example output' response = nil; want: example output",
		)
	}

	bytes, err := ioutil.ReadAll(runCmdResponse)

	if err != nil {
		t.Errorf(
			"cmdRun() ioutil.ReadAll(runCmdResponse) err = %s",
			err,
		)
	}

	if len(bytes) == 0 {
		t.Errorf(
			"cmdRun() ioutil.ReadAll(runCmdResponse) was empty / blank.",
		)
	}

	got := string(bytes)

	if got != "example output\n" {
		t.Errorf(
			"cmdRun() output = %s; want: %s; len(bytes): %d",
			got,
			"example output\n",
			len(bytes),
		)
	}

	if exitStatusChannel == nil {
		t.Errorf(
			"cmdRun() 'echo example output' exitStatusChannel = nil; want: not nil",
		)
	} else {
		exitStatus := <-exitStatusChannel

		if exitStatus != 0 {
			t.Errorf(
				"cmdRun() 'echo example output' exitStatus = %v; want: 0",
				exitStatus,
			)
		}
	}
}

func TestCmdRunRequiresCommand(t *testing.T) {
	cfg := config{
		nbDir:          filepath.Join("tmp", "example-nb-dir"),
		nbNotebookPath: filepath.Join("tmp", "example-nb-dir", "home"),
	}

	runCmdResponse, exitStatusChannel, err := cmdRun(
		subcommandCall{
			cfg:         cfg,
			inputReader: nil,
			args:        []string{},
			env:         os.Environ(),
			options:     map[string]string{"execType": "goroutine"},
		},
	)

	errMessage := fmt.Sprintf("%s", err)

	if errMessage != "Command required." {
		t.Errorf(
			"cmdRun() (no command) errMessage = %s; want: %s.",
			errMessage,
			"Command required.",
		)
	}

	if exitStatusChannel != nil {
		t.Errorf(
			"cmdRun() (no command) exitStatusChannel = %v; want: nil",
			exitStatusChannel,
		)
	}

	if runCmdResponse != nil {
		t.Errorf(
			"cmdRun() (no command) standard output should be nil.",
		)
	}
}

// TODO: Test for current notebook directory.
func TestCmdRunRunsInNbNotebookPath(t *testing.T) {
	// TODO: Create temp directories.
	// cfg := config{
	//   nbDir:          filepath.Join("tmp", "example-nb-dir"),
	//   nbNotebookPath: filepath.Join("tmp", "example-nb-dir", "home"),
	// }

	cfg, _ := configure()

	runCmdResponse, exitStatusChannel, err := cmdRun(
		subcommandCall{
			cfg:         cfg,
			inputReader: nil,
			args:        []string{"pwd"},
			env:         os.Environ(),
			options:     map[string]string{"execType": "goroutine"},
		},
	)

	if err != nil {
		t.Errorf(
			"cmdRun() err = %s",
			err,
		)
	}

	if runCmdResponse == nil {
		t.Errorf(
			"cmdRun() 'pwd' response = nil; want: `pwd`",
		)
	}

	bytes, err := ioutil.ReadAll(runCmdResponse)

	if err != nil {
		t.Errorf(
			"cmdRun() ioutil.ReadAll(runCmdResponse) err = %s",
			err,
		)
	}

	if len(bytes) == 0 {
		t.Errorf(
			"cmdRun() ioutil.ReadAll(runCmdResponse) was empty / blank.",
		)
	}

	// TODO: Requires temp notebook path.
	// got := string(bytes)
	//
	// if got != cfg.nbNotebookPath {
	//   t.Errorf(
	//     "cmdRun() output = %s; want: %s; len(bytes): %d",
	//     got,
	//     cfg.nbNotebookPath,
	//     len(bytes),
	//   )
	// }

	if exitStatusChannel == nil {
		t.Errorf(
			"cmdRun() 'pwd' exitStatusChannel = nil; want: not nil",
		)
	} else {
		exitStatus := <-exitStatusChannel

		if exitStatus != 0 {
			t.Errorf(
				"cmdRun() 'pwd' exitStatus = %v; want: 0",
				exitStatus,
			)
		}
	}
}

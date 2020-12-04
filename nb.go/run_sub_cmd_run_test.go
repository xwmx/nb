package main

import (
	"fmt"
	"io/ioutil"
	"os"
	// "path/filepath"
	"testing"
)

func TestRunSubCmdRunPrintsOutput(t *testing.T) {
	// TODO: Create temp directories.
	// cfg := config{
	//   nbDir:          filepath.Join("tmp", "example-nb-dir"),
	//   nbNotebookPath: filepath.Join("tmp", "example-nb-dir", "home"),
	// }

	cfg, err := configure()
	if err != nil {
		t.Errorf(
			"runSubCmdRun() configure() err = %s",
			err,
		)
	}

	runCmdResponse, exitStatusChannel, err := runSubCmdRun(
		subCmdCall{
			args:        []string{"echo", "example output"},
			cfg:         cfg,
			env:         os.Environ(),
			inputReader: nil,
			options:     map[string]string{"execType": "goroutine"},
		},
	)

	if err != nil {
		t.Errorf(
			"runSubCmdRun() err = %s; %v",
			err,
			cfg.nbNotebookPath,
		)
	}

	var bytes []byte

	if runCmdResponse == nil {
		t.Errorf(
			"runSubCmdRun() 'echo example output' response\ngot:  nil\nwant: 'example output'",
		)
	} else {
		bytes, err = ioutil.ReadAll(runCmdResponse)
	}

	if err != nil {
		t.Errorf(
			"runSubCmdRun() ioutil.ReadAll(runCmdResponse) err = %s",
			err,
		)
	}

	if len(bytes) == 0 {
		t.Errorf(
			"runSubCmdRun() ioutil.ReadAll(runCmdResponse) was empty / blank.",
		)
	}

	got := string(bytes)

	if got != "example output\n" {
		t.Errorf(
			"runSubCmdRun() output = %s; want: %s; len(bytes): %d",
			got,
			"example output\n",
			len(bytes),
		)
	}

	if exitStatusChannel == nil {
		t.Errorf(
			"runSubCmdRun() 'echo example output' exitStatusChannel = nil; want: not nil",
		)
	} else {
		exitStatus := <-exitStatusChannel

		if exitStatus != 0 {
			t.Errorf(
				"runSubCmdRun() 'echo example output' exitStatus = %v; want: 0",
				exitStatus,
			)
		}
	}
}

func TestRunSubCmdRunRequiresCommand(t *testing.T) {
	// cfg := config{
	//   nbDir:          filepath.Join("tmp", "example-nb-dir"),
	//   nbNotebookPath: filepath.Join("tmp", "example-nb-dir", "home"),
	// }

	cfg, err := configure()
	if err != nil {
		t.Errorf(
			"runSubCmdRun() configure() err = %s",
			err,
		)
	}

	runCmdResponse, exitStatusChannel, err := runSubCmdRun(
		subCmdCall{
			cfg:         cfg,
			inputReader: nil,
			args:        []string{},
			env:         os.Environ(),
			// options:     map[string]string{"execType": "goroutine"},
		},
	)

	errMessage := fmt.Sprintf("%s", err)

	if errMessage != "Command required." {
		t.Errorf(
			"runSubCmdRun() (no command) errMessage = %s; want: %s.",
			errMessage,
			"Command required.",
		)
	}

	if exitStatusChannel != nil {
		t.Errorf(
			"runSubCmdRun() (no command) exitStatusChannel = %v; want: nil",
			exitStatusChannel,
		)
	}

	if runCmdResponse != nil {
		t.Errorf(
			"runSubCmdRun() (no command) standard output should be nil.",
		)
	}
}

// TODO: Test for current notebook directory.
func TestRunSubCmdRunRunsInNbNotebookPath(t *testing.T) {
	// TODO: Create temp directories.
	// cfg := config{
	//   nbDir:          filepath.Join("tmp", "example-nb-dir"),
	//   nbNotebookPath: filepath.Join("tmp", "example-nb-dir", "home"),
	// }

	cfg, err := configure()
	if err != nil {
		t.Errorf(
			"runSubCmdRun() configure() err = %s",
			err,
		)
	}

	runCmdResponse, exitStatusChannel, err := runSubCmdRun(
		subCmdCall{
			cfg:         cfg,
			inputReader: nil,
			args:        []string{"pwd"},
			env:         os.Environ(),
			// options:     map[string]string{"execType": "goroutine"},
		},
	)

	if err != nil {
		t.Errorf(
			"runSubCmdRun() err = %s",
			err,
		)
	}

	if runCmdResponse == nil {
		t.Errorf(
			"runSubCmdRun() 'pwd' response = nil; want: `pwd`",
		)
	}

	bytes, err := ioutil.ReadAll(runCmdResponse)

	if err != nil {
		t.Errorf(
			"runSubCmdRun() ioutil.ReadAll(runCmdResponse) err = %s",
			err,
		)
	}

	if len(bytes) == 0 {
		t.Errorf(
			"runSubCmdRun() ioutil.ReadAll(runCmdResponse) was empty / blank.",
		)
	}

	// TODO: Requires temp notebook path.
	// got := string(bytes)
	//
	// if got != cfg.nbNotebookPath {
	//   t.Errorf(
	//     "runSubCmdRun() output = %s; want: %s; len(bytes): %d",
	//     got,
	//     cfg.nbNotebookPath,
	//     len(bytes),
	//   )
	// }

	if exitStatusChannel == nil {
		t.Errorf(
			"runSubCmdRun() 'pwd' exitStatusChannel = nil; want: not nil",
		)
	} else {
		exitStatus := <-exitStatusChannel

		if exitStatus != 0 {
			t.Errorf(
				"runSubCmdRun() 'pwd' exitStatus = %v; want: 0",
				exitStatus,
			)
		}
	}
}

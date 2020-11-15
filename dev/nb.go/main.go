package main

import (
	// "fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"syscall"
)

type configuration struct {
	NBDir string
}

func (config *configuration) load() error {
	dir := os.Getenv("NB_DIR")

	if dir == "" {
		if runtime.GOOS == "windows" {
			dir = os.Getenv("APPDATA")

			if dir == "" {
				dir = filepath.Join(os.Getenv("USERPROFILE"), "Application Data", "nb")
			}

			dir = filepath.Join(dir, "nb")
		} else {
			dir = filepath.Join(os.Getenv("HOME"), ".nb")
		}
	}

	config.NBDir = dir

	return nil
}

func runScript() int {
	var config configuration

	err := config.load()
	if err != nil {
		log.Println(err)
		return 1
	}

	binary, lookErr := exec.LookPath("nb")
	if lookErr != nil {
		log.Println(lookErr)
		return 1
	}

	args := os.Args
	env := os.Environ()

	execErr := syscall.Exec(binary, args, env)
	if execErr != nil {
		log.Println(execErr)
		return 1
	}

	return 0
}

func main() {
	os.Exit(runScript())
}

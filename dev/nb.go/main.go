package main

import (
	// "fmt"
	"log"
	"os"
	"os/exec"
	"syscall"
)

func runScript() int {
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

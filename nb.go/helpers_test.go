package main

import (
	"bytes"
	"log"
	"os"
)

// https://stackoverflow.com/a/26806093
func captureLogOutput(f func()) string {
	var buf bytes.Buffer
	log.SetOutput(&buf)
	f()
	log.SetOutput(os.Stderr)
	return buf.String()
}

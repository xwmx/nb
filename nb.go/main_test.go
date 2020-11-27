// revive:disable:error-strings Errors should match existing `nb` formatting.

package main

import (
	"errors"
	"testing"
)

// present

func TestPresentWithErrorReturns1(t *testing.T) {
	exitCode := present(nil, errors.New("Test error."))
	if exitCode != 1 {
		t.Errorf("present exitCode incorrect. got: %d, want: %d.", exitCode, 1)
	}
}

func TestPresentWithNoErrorReturns0(t *testing.T) {
	exitCode := present(nil, nil)
	if exitCode != 0 {
		t.Errorf("present exitCode incorrect. got: %d, want: %d.", exitCode, 1)
	}
}

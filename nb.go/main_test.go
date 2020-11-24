// revive:disable:error-strings Errors should match existing `nb` formatting.

package main

import (
	"errors"
	"testing"
)

// presentErrort

func TestPresentErrorWithErrorReturns1(t *testing.T) {
	exitCode := presentError(errors.New("Test error."))
	if exitCode != 1 {
		t.Errorf("presentError exitCode incorrect. got: %d, want: %d.", exitCode, 1)
	}
}

func TestPresentErrorWithNoErrorReturns0(t *testing.T) {
	exitCode := presentError(nil)
	if exitCode != 0 {
		t.Errorf("presentError exitCode incorrect. got: %d, want: %d.", exitCode, 1)
	}
}

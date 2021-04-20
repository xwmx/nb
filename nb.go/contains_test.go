// revive:disable:error-strings Errors should match existing `nb` formatting.

package main

import (
	"testing"
)

func TestContainsWithMatchReturnsTrue(t *testing.T) {
	slice := []string{"one", "two", "three"}
	query := "two"

	if !contains(slice, query) {
		t.Errorf(
			"contains() expected match not found. slice: %v; element: %v.",
			slice,
			query,
		)
	}
}

func TestContainsWithNoMatchReturnsFalse(t *testing.T) {
	slice := []string{"one", "two", "three"}
	query := "not-valid"

	if contains(slice, query) {
		t.Errorf(
			"contains() unexpected match found. slice: %v; element: %v.",
			slice,
			query,
		)
	}
}

package main

import (
	"testing"
)

func TestCheckNonPrimitive(t *testing.T) {
	tests := []struct {
		input    string
		expected bool
	}{
		{"abab", true},
		{"aaaa", true},
		{"abcabc", true},
		{"abcabcabcabcabcabcabcabcabcabc", true},
		{"878787", true},
		{"abcd", false},
		{"a", false},
	}

	for _, tt := range tests {
		got := checkNonPrimitive(tt.input)
		if got != tt.expected {
			t.Errorf("checkNonPrimitive(%q) = %v, expected %v", tt.input, got, tt.expected)
		}
	}
}

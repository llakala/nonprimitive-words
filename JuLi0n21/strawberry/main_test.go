package main

import (
	"strconv"
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

func TestMatchExpectedCount(t *testing.T) {
	expectedCount := 1107
	count := 0
	for i := 0; i < 10_000_000; i++ {
		str := strconv.Itoa(i)
		if checkNonPrimitive(str) {
			count++
		}
	}
	if count != expectedCount {
		t.Errorf("Expected %d non-primitive words, but got %d", expectedCount, count)
	}
}

func TestMatchExpectedCountCheating(t *testing.T) {
	expectedCount := 1107
	count := 0
	for i := 0; i < 10_000_000; i++ {
		str := strconv.Itoa(i)
		if checkNonPrimitiveContains(str) {
			count++
		}
	}
	if count != expectedCount {
		t.Errorf("Expected %d non-primitive words, but got %d", expectedCount, count)
	}
}

package main

import (
	"fmt"
	"strconv"
	"time"
)

func main() {

	start := time.Now()
	for i := range 10_000_000 {
		str := strconv.Itoa(i)
		if checkNonPrimitive(str) {
			fmt.Println(str)
		}
	}
	fmt.Println("Took: ", time.Since(start).Milliseconds(), "ms")

}

func checkNonPrimitive(value string) bool {

	devisors := findDevisors(value)

	for _, divs := range devisors {
		subStrings := []string{}

		if divs == 1 {
			continue
		}

		splitLength := len(value) / divs
		for index := 0; index < len(value); index += splitLength {
			subStrings = append(subStrings, value[index:index+splitLength])
		}

		if len(subStrings) == 0 {
			continue
		}

		first := subStrings[0]
		allSame := true
		for _, s := range subStrings[1:] {
			if s != first {
				allSame = false
				break

			}
		}

		if allSame {
			return true
		}

	}
	return false
}

func findDevisors(value string) []int {

	var devisiors = []int{}
	if len(value) == 1 {
		return []int{}
	}

	devisiors = append(devisiors, len(value))

	for i := 1; i <= len(value)/2; i++ {
		if len(value)%i == 0 {
			devisiors = append(devisiors, i)
		}
	}

	return devisiors

}

package main

import (
	"flag"
	"fmt"
	"strconv"
	"strings"
	"time"
)

func main() {

	upper := flag.Int("limit", 10_000_000, "Upper bound for numeric loop")
	custom := flag.String("custom", "", "Custom string to test (skips loop)")
	method := flag.String("method", "normal", "Method to use: normal | contains")
	timing := flag.Bool("time", true, "Print execution timing (default: true)")

	flag.Parse()

	var fn func(string) bool
	switch *method {
	case "contains":
		fn = checkNonPrimitiveContains
	default:
		fn = checkNonPrimitive
	}

	start := time.Now()

	if *custom != "" {
		fmt.Printf("Testing string %q -> %v\n", *custom, fn(*custom))
	} else {
		for i := 0; i < *upper; i++ {
			str := strconv.Itoa(i)
			if fn(str) {
				fmt.Println(str)
			}
		}
	}

	if *timing {
		fmt.Printf("Took: %d ms\n", time.Since(start).Milliseconds())
	}

}

func checkNonPrimitive(value string) bool {

	for divs := 2; divs <= len(value); divs++ {
		subStrings := []string{}

		if len(value)%divs != 0 {
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

func checkNonPrimitiveContains(value string) bool {
	if len(value) < 2 {
		return false
	}
	concated := value + value
	return strings.Contains(concated[1:len(concated)-1], value)
}

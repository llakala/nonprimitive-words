#!/usr/bin/env bash

# Benchmark script for check_nonprimitive.py
# Tests specified numbers of non-primitive and primitive numbers
# Measures average execution time and standard deviation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/check_nonprimitive.py"

# Parse and validate arguments
validate_arguments() {
    if [[ $# -ne 3 ]]; then
        echo "Usage: $0 <num_tests> <min_digits> <max_digits>"
        echo "  num_tests: number of tests to run for each type (non-primitive and primitive)"
        echo "  min_digits: minimum digit length"
        echo "  max_digits: maximum digit length"
        exit 1
    fi

    NUM_TESTS=$1
    MIN_DIGITS=$2
    MAX_DIGITS=$3

    # Validate arguments
    if ! [[ "$NUM_TESTS" =~ ^[0-9]+$ ]] || [[ $NUM_TESTS -le 0 ]]; then
        echo "Error: num_tests must be a positive integer"
        exit 1
    fi

    if ! [[ "$MIN_DIGITS" =~ ^[0-9]+$ ]] || [[ $MIN_DIGITS -le 0 ]]; then
        echo "Error: min_digits must be a positive integer"
        exit 1
    fi

    if ! [[ "$MAX_DIGITS" =~ ^[0-9]+$ ]] || [[ $MAX_DIGITS -lt $MIN_DIGITS ]]; then
        echo "Error: max_digits must be a positive integer >= min_digits"
        exit 1
    fi

    # Check if check_nonprimitive.py exists
    if [[ ! -f "$CHECK_SCRIPT" ]]; then
        echo "Error: $CHECK_SCRIPT not found"
        exit 1
    fi
}

# Generate non-primitive number by repeating a pattern
generate_nonprimitive_number() {
    local target_digits=$1
    
    # For very small numbers, use simple repetition
    if [[ $target_digits -eq 1 ]]; then
        # Single digit can't be non-primitive, return 2-digit
        local digit=$((RANDOM % 9 + 1))
        echo "${digit}${digit}"
        return
    fi
    
    # Choose pattern length that divides target_digits evenly
    local divisors=()
    for ((p=1; p<target_digits; p++)); do
        if [[ $((target_digits % p)) -eq 0 ]]; then
            divisors+=($p)
        fi
    done
    
    if [[ ${#divisors[@]} -eq 0 ]]; then
        # No exact divisors, use simple doubling
        local half=$((target_digits / 2))
        local pattern=""
        pattern=$((RANDOM % 9 + 1))  # First digit 1-9
        for ((i=1; i<half; i++)); do
            pattern+=$((RANDOM % 10))
        done
        echo "${pattern}${pattern}"
        return
    fi
    
    # Pick a random divisor as pattern length
    local pattern_length=${divisors[$((RANDOM % ${#divisors[@]}))]}
    
    # Generate base pattern
    local pattern=""
    pattern=$((RANDOM % 9 + 1))  # First digit 1-9
    for ((i=1; i<pattern_length; i++)); do
        pattern+=$((RANDOM % 10))
    done
    
    # Repeat pattern exactly to fill target digits
    local repetitions=$((target_digits / pattern_length))
    local result=""
    for ((i=0; i<repetitions; i++)); do
        result+="$pattern"
    done
    
    echo "$result"
}

# Generate primitive number (non-repeating pattern)
generate_primitive_number() {
    local digits=$1
    
    # Generate number with non-repeating pattern
    local number=""
    number=$((RANDOM % 9 + 1))  # First digit 1-9
    
    for ((i=1; i<digits; i++)); do
        # Use varied pattern to avoid repetition
        local digit=$(((RANDOM + i * 3 + 1) % 10))
        number+="$digit"
    done
    
    echo "$number"
}

# Calculate statistics using Python
calculate_stats() {
    local -n times_array=$1
    
    # Convert array to comma-separated string for Python
    local times_str=""
    for i in "${!times_array[@]}"; do
        if [[ $i -eq 0 ]]; then
            times_str="${times_array[i]}"
        else
            times_str="${times_str},${times_array[i]}"
        fi
    done
    
    # Use Python for reliable floating point arithmetic
    python3 -c "
import math

times = [$times_str]
count = len(times)
mean = sum(times) / count
variance = sum((x - mean) ** 2 for x in times) / count
stdev = math.sqrt(variance)
total = sum(times)

print(f'{mean:.6f} {stdev:.6f} {total:.6f} {count}')
"
}

# Run benchmark for a specific type of numbers
run_benchmark() {
    local test_type=$1
    local num_tests=$2
    local min_digits=$3
    local max_digits=$4
    
    echo "Testing $test_type numbers... (0/$num_tests)"
    
    local -a execution_times
    local -a digit_counts
    local -a test_numbers
    
    for ((i=1; i<=num_tests; i++)); do
        # Generate random digit count in range
        local digit_count=$((RANDOM % (max_digits - min_digits + 1) + min_digits))
        
        # Generate test number based on type
        local test_number
        if [[ "$test_type" == "non-primitive" ]]; then
            test_number=$(generate_nonprimitive_number $digit_count)
        else
            test_number=$(generate_primitive_number $digit_count)
        fi
        
        # Measure execution time
        local start_time=$(date +%s.%N)
        local result=$(uv run "$CHECK_SCRIPT" "$test_number" 2>/dev/null || echo "ERROR")
        local end_time=$(date +%s.%N)
        
        local execution_time=$(echo "$end_time - $start_time" | bc -l)
        
        # Store results
        execution_times+=($execution_time)
        digit_counts+=($digit_count)
        test_numbers+=($test_number)
        
        # Progress indicator with timing info - more frequent for larger runs
        local progress_interval=5
        if [[ $num_tests -gt 50 ]]; then
            progress_interval=10
        elif [[ $num_tests -gt 100 ]]; then
            progress_interval=20
        fi
        
        if [[ $((i % progress_interval)) -eq 0 ]] || [[ $num_tests -le 10 ]] || [[ $i -eq $num_tests ]]; then
            echo "  Completed $i/$num_tests $test_type tests... (last: ${digit_count}d, ${execution_time}s)"
        fi
        
        # Assert output format is correct and verify result matches expectation
        if [[ "$result" == "ERROR" ]]; then
            echo "  ERROR: Failed to run check_nonprimitive.py on $test_number"
            exit 1
        fi
        
        # Check that output format is correct (should contain either "primitive" or "non-primitive")
        if [[ "$result" != *"primitive"* ]] && [[ "$result" != *"non-primitive"* ]]; then
            echo "  ERROR: Unexpected output format from check_nonprimitive.py: '$result'"
            echo "  Expected output to contain 'primitive' or 'non-primitive'"
            exit 1
        fi
        
        # Verify the result matches expectation
        if [[ "$test_type" == "non-primitive" ]] && [[ "$result" != *"non-primitive"* ]]; then
            echo "  ERROR: Generated $test_type number $test_number ($digit_count digits) classified as: $result"
            echo "  This indicates a bug in either the generation logic or the classification script"
            exit 1
        elif [[ "$test_type" == "primitive" ]] && [[ "$result" == *"non-primitive"* ]]; then
            echo "  ERROR: Generated $test_type number $test_number ($digit_count digits) classified as: $result"
            echo "  This indicates a bug in either the generation logic or the classification script"
            exit 1
        fi
    done
    
    # Calculate and return statistics
    if [[ ${#execution_times[@]} -gt 0 ]]; then
        local stats_result=$(calculate_stats execution_times)
        echo "$stats_result"
    fi
}

# Main execution
main() {
    validate_arguments "$@"
    
    echo "Benchmarking check_nonprimitive.py with $NUM_TESTS non-primitive and $NUM_TESTS primitive numbers"
    echo "Digit length range: $MIN_DIGITS to $MAX_DIGITS"
    echo "----------------------------------------"
    
    # Run benchmarks with real-time progress using temp files for stats
    echo "Phase 1: Testing non-primitive numbers..."
    run_benchmark "non-primitive" $NUM_TESTS $MIN_DIGITS $MAX_DIGITS | while IFS= read -r line; do
        echo "$line"
        if [[ "$line" =~ ^[0-9]+\.[0-9]+ ]]; then
            echo "$line" > /tmp/nonprim_stats.txt
        fi
    done
    local nonprim_stats=""
    [[ -f /tmp/nonprim_stats.txt ]] && nonprim_stats=$(cat /tmp/nonprim_stats.txt)
    
    echo ""
    echo "Phase 2: Testing primitive numbers..."
    run_benchmark "primitive" $NUM_TESTS $MIN_DIGITS $MAX_DIGITS | while IFS= read -r line; do
        echo "$line"
        if [[ "$line" =~ ^[0-9]+\.[0-9]+ ]]; then
            echo "$line" > /tmp/prim_stats.txt
        fi
    done  
    local prim_stats=""
    [[ -f /tmp/prim_stats.txt ]] && prim_stats=$(cat /tmp/prim_stats.txt)
    
    echo "----------------------------------------"
    echo "BENCHMARK RESULTS"
    echo "----------------------------------------"
    
    # Parse and display non-primitive results
    if [[ -n "$nonprim_stats" ]]; then
        read -r np_mean np_stdev np_total np_count <<< "$nonprim_stats"
        echo "Non-primitive numbers:"
        echo "  Tests: $np_count"
        echo "  Total time: ${np_total}s"
        echo "  Average time: ${np_mean}s"
        echo "  Std deviation: ${np_stdev}s"
    fi
    
    echo ""
    
    # Parse and display primitive results  
    if [[ -n "$prim_stats" ]]; then
        read -r p_mean p_stdev p_total p_count <<< "$prim_stats"
        echo "Primitive numbers:"
        echo "  Tests: $p_count"
        echo "  Total time: ${p_total}s"
        echo "  Average time: ${p_mean}s"
        echo "  Std deviation: ${p_stdev}s"
    fi
    
    echo ""
    echo "Benchmark completed successfully!"
}

# Run main function with all arguments
main "$@"
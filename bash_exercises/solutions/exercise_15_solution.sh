#!/bin/bash
# Exercise 15 Solution: Automated Testing Framework

# STEP 1: Setup colors and variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_DIR="tests"
PARALLEL_JOBS=1
OUTPUT_FORMAT="console"
OUTPUT_FILE=""
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# STEP 2: Usage function
show_usage() {
    echo "Usage: bash test_runner.sh [options]"
    echo "Options:"
    echo "  --test-dir DIR      Test directory (default: tests)"
    echo "  --file FILE         Run specific test file"
    echo "  --parallel          Enable parallel execution"
    echo "  --jobs N            Number of parallel jobs (default: 1)"
    echo "  --output FORMAT     Output format (console, html, xml, json)"
    echo "  --report FILE       Output report file"
    echo "  --coverage          Enable coverage tracking"
    echo "  --ci                CI mode (exit with error code)"
}

# STEP 3: Test assertion functions
assert_equals() {
    local expected=$1
    local actual=$2
    local message=${3:-"Assertion failed"}
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓ PASS: $message${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL: $message${NC}"
        echo -e "${RED}  Expected: '$expected'${NC}"
        echo -e "${RED}  Actual: '$actual'${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

assert_true() {
    local condition=$1
    local message=${2:-"Assertion failed"}
    
    if [[ $condition -eq 0 ]]; then
        assert_equals "true" "true" "$message"
    else
        assert_equals "true" "false" "$message"
    fi
}

assert_false() {
    local condition=$1
    local message=${2:-"Assertion failed"}
    
    if [[ $condition -ne 0 ]]; then
        assert_equals "false" "false" "$message"
    else
        assert_equals "false" "true" "$message"
    fi
}

# STEP 4: Test discovery function
discover_tests() {
    local test_dir=$1
    find "$test_dir" -name "test_*.sh" -type f
}

# STEP 5: Run single test file
run_test_file() {
    local test_file=$1
    local test_name=$(basename "$test_file" .sh)
    
    echo -e "${BLUE}Running test: $test_name${NC}"
    
    # Source the test file and run setup if exists
    source "$test_file"
    
    # Run setup function if it exists
    if declare -f setup >/dev/null; then
        setup
    fi
    
    # Find and run all test functions
    local test_functions=$(declare -F | grep "declare -f test_" | awk '{print $3}')
    
    for test_func in $test_functions; do
        echo -e "${YELLOW}  → $test_func${NC}"
        $test_func
    done
    
    # Run teardown function if it exists
    if declare -f teardown >/dev/null; then
        teardown
    fi
    
    echo ""
}

# STEP 6: Run tests in parallel
run_parallel_tests() {
    local test_files=("$@")
    local pids=()
    
    for test_file in "${test_files[@]}"; do
        # Wait if we've reached max jobs
        while [[ ${#pids[@]} -ge $PARALLEL_JOBS ]]; do
            for i in "${!pids[@]}"; do
                if ! kill -0 "${pids[i]}" 2>/dev/null; then
                    unset "pids[i]"
                fi
            done
            pids=("${pids[@]}")  # Reindex array
            sleep 0.1
        done
        
        # Start new test in background
        run_test_file "$test_file" &
        pids+=($!)
    done
    
    # Wait for all remaining tests
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
}

# STEP 7: Generate HTML report
generate_html_report() {
    local output_file=${OUTPUT_FILE:-"test_report.html"}
    
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .pass { color: green; }
        .fail { color: red; }
        .summary { background: #f0f0f0; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Test Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <p>Total Tests: $TOTAL_TESTS</p>
        <p class="pass">Passed: $PASSED_TESTS</p>
        <p class="fail">Failed: $FAILED_TESTS</p>
        <p>Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%</p>
    </div>
    <p>Generated: $(date)</p>
</body>
</html>
EOF
    
    echo -e "${GREEN}HTML report generated: $output_file${NC}"
}

# STEP 8: Generate XML report (JUnit format)
generate_xml_report() {
    local output_file=${OUTPUT_FILE:-"test_report.xml"}
    
    cat > "$output_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite tests="$TOTAL_TESTS" failures="$FAILED_TESTS" time="0">
    <testcase classname="BashTests" name="AllTests" time="0">
        $(if [[ $FAILED_TESTS -gt 0 ]]; then echo '<failure message="Some tests failed"/>'; fi)
    </testcase>
</testsuite>
EOF
    
    echo -e "${GREEN}XML report generated: $output_file${NC}"
}

# STEP 9: Show test summary
show_summary() {
    echo -e "${BLUE}=== Test Summary ===${NC}"
    echo -e "${BLUE}Total Tests: $TOTAL_TESTS${NC}"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        local success_rate=$(( PASSED_TESTS * 100 / TOTAL_TESTS ))
        echo -e "${BLUE}Success Rate: ${success_rate}%${NC}"
    fi
    
    echo ""
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}All tests passed! ✓${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed! ✗${NC}"
        return 1
    fi
}

# STEP 10: Main function
main() {
    local test_file=""
    local enable_parallel=false
    local enable_coverage=false
    local ci_mode=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --test-dir) TEST_DIR=$2; shift 2 ;;
            --file) test_file=$2; shift 2 ;;
            --parallel) enable_parallel=true; shift ;;
            --jobs) PARALLEL_JOBS=$2; shift 2 ;;
            --output) OUTPUT_FORMAT=$2; shift 2 ;;
            --report) OUTPUT_FILE=$2; shift 2 ;;
            --coverage) enable_coverage=true; shift ;;
            --ci) ci_mode=true; shift ;;
            --help) show_usage; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; show_usage; exit 1 ;;
        esac
    done
    
    echo -e "${BLUE}=== Bash Test Runner ===${NC}"
    echo ""
    
    # Run specific test file or discover tests
    if [[ -n "$test_file" ]]; then
        run_test_file "$test_file"
    else
        local test_files=($(discover_tests "$TEST_DIR"))
        
        if [[ ${#test_files[@]} -eq 0 ]]; then
            echo -e "${YELLOW}No test files found in $TEST_DIR${NC}"
            exit 0
        fi
        
        if [[ "$enable_parallel" == true && $PARALLEL_JOBS -gt 1 ]]; then
            run_parallel_tests "${test_files[@]}"
        else
            for test_file in "${test_files[@]}"; do
                run_test_file "$test_file"
            done
        fi
    fi
    
    # Generate reports
    case $OUTPUT_FORMAT in
        html) generate_html_report ;;
        xml) generate_xml_report ;;
        json) echo '{"total":'$TOTAL_TESTS',"passed":'$PASSED_TESTS',"failed":'$FAILED_TESTS'}' ;;
    esac
    
    # Show summary and exit
    show_summary
    local exit_code=$?
    
    if [[ "$ci_mode" == true ]]; then
        exit $exit_code
    fi
}

main "$@"
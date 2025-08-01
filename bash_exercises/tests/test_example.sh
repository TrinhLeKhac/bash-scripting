#!/bin/bash
# Example test file for testing framework

# STEP 1: Setup function (runs before tests)
setup() {
    echo "Setting up test environment..."
    TEST_DATA_DIR="/tmp/test_data"
    mkdir -p "$TEST_DATA_DIR"
}

# STEP 2: Teardown function (runs after tests)
teardown() {
    echo "Cleaning up test environment..."
    rm -rf "$TEST_DATA_DIR"
}

# STEP 3: Test basic arithmetic
test_addition() {
    local result=$((5 + 3))
    assert_equals 8 "$result" "5 + 3 should equal 8"
}

test_subtraction() {
    local result=$((10 - 4))
    assert_equals 6 "$result" "10 - 4 should equal 6"
}

# STEP 4: Test string operations
test_string_length() {
    local str="hello"
    local length=${#str}
    assert_equals 5 "$length" "Length of 'hello' should be 5"
}

test_string_concatenation() {
    local str1="hello"
    local str2="world"
    local result="${str1} ${str2}"
    assert_equals "hello world" "$result" "String concatenation test"
}

# STEP 5: Test file operations
test_file_creation() {
    local test_file="$TEST_DATA_DIR/test.txt"
    echo "test content" > "$test_file"
    assert_true "[[ -f '$test_file' ]]" "Test file should be created"
}

test_file_content() {
    local test_file="$TEST_DATA_DIR/test.txt"
    echo "expected content" > "$test_file"
    local content=$(cat "$test_file")
    assert_equals "expected content" "$content" "File content should match"
}

# STEP 6: Test command execution
test_command_success() {
    assert_true "echo 'test' >/dev/null" "Echo command should succeed"
}

test_command_failure() {
    assert_false "false" "False command should fail"
}
#!/bin/bash

# SBT Run Examples Script
set -euo pipefail

echo "🚀 SBT Run Examples Demo"

echo ""
echo "📋 Available sample files in data/ directory:"
echo "  - sample_data.csv (basic dataset)"
echo "  - test_data.csv (mixed positive/negative)"
echo "  - large_data.csv (larger dataset)"
echo "  - financial_data.csv (financial values)"
echo "  - sensor_readings.csv (temperature readings)"

echo ""
echo "🎯 Example 1: Default run (no arguments)"
echo "Command: sbt run"
sbt -warn run

echo ""
echo "🎯 Example 2: Process sample_data.csv file"
echo "Command: sbt \"run --file data/sample_data.csv\""
sbt -warn "run --file data/sample_data.csv"

echo ""
echo "🎯 Example 3: Process test_data.csv file"
echo "Command: sbt \"run --file data/test_data.csv\""
sbt -warn "run --file data/test_data.csv"

echo ""
echo "🎯 Example 4: Process inline data (simple)"
echo "Command: sbt \"run --data 1,2,3,4,5\""
sbt -warn "run --data 1,2,3,4,5"

echo ""
echo "🎯 Example 5: Process inline data (mixed positive/negative)"
echo "Command: sbt \"run --data 10,-5,15,-10,20\""
sbt -warn "run --data 10,-5,15,-10,20"

echo ""
echo "🎯 Example 6: Process inline data (decimals)"
echo "Command: sbt \"run --data 1.5,2.7,-3.2,4.8,-5.1\""
sbt -warn "run --data 1.5,2.7,-3.2,4.8,-5.1"

echo ""
echo "🎯 Example 7: Process large dataset"
echo "Command: sbt \"run --file data/large_data.csv\""
sbt -warn "run --file data/large_data.csv"

echo ""
echo "🎯 Example 8: Process financial data"
echo "Command: sbt \"run --file data/financial_data.csv\""
sbt -warn "run --file data/financial_data.csv"

echo ""
echo "🎯 Example 9: Process sensor readings"
echo "Command: sbt \"run --file data/sensor_readings.csv\""
sbt -warn "run --file data/sensor_readings.csv"

echo ""
echo "🎯 Example 10: Show help"
echo "Command: sbt \"run --help\""
sbt -warn "run --help"

echo ""
echo "✅ All examples completed!"
echo ""
echo "💡 Quick reference:"
echo "  sbt run                              # Default sample processing"
echo "  sbt \"run --file <filename>\"          # Process CSV file"
echo "  sbt \"run --data <numbers>\"           # Process comma-separated numbers"
echo "  sbt \"run --help\"                     # Show help"
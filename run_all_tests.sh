#!/bin/bash

echo "========================================="
echo "         SDR++CE TEST SUITE"
echo "========================================="
echo ""

# Run all tests in sequence
echo "Running test_functionality.sh..."
echo "========================================="
./test_functionality.sh
echo ""

echo "Running test_symbol_export.sh..."
echo "========================================="
./test_symbol_export.sh
echo ""

echo "Running test_app_startup.sh..."
echo "========================================="
./test_app_startup.sh
echo ""

echo "========================================="
echo "         TEST SUITE COMPLETE"
echo "========================================="
echo ""
echo "Summary:"
echo "- test_functionality.sh: Checks code and build artifacts"
echo "- test_symbol_export.sh: Verifies symbol exports"
echo "- test_app_startup.sh: Tests actual app launch"
echo ""
echo "Review logs above to identify issues."


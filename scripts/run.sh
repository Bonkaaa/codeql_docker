#!/bin/bash

# Navigate to the juice-shop directory
cd juice-shop || { echo "juice-shop directory not found! Please run clone.sh first."; exit 1; }

# Create database
echo "Creating database..."
codeql database create ../juice-db --language=javascript --overwrite

# Finalize
echo "Finalizing database..."
codeql database finalize ../juice-db

# Navigate back 1 directory
cd ..

# Run analysis
echo "Running CodeQL analysis..."
codeql database analyze juice-db codeql/javascript-queries:codeql-suites/javascript-security-and-quality.qls --format=sarif-latest --output=results.sarif

echo "Analysis complete. Results saved to results.sarif"
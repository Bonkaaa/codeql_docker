#!/bin/bash

# CodeQL Version
echo "Using CodeQL version"
codeql version


# Navigate to the juice-shop directory
cd juice-shop || { echo "juice-shop directory not found! Please run clone.sh first."; exit 1; }

# Create database
echo "Creating database..."
DB_NAME="db-${CODEQL_VERSION}"
codeql database create ../$DB_NAME --language=javascript --overwrite

# Finalize
echo "Finalizing database..."
codeql database finalize ../$DB_NAME

# Navigate back 1 directory
cd ..

# Run analysis
echo "Running CodeQL analysis..."
codeql database analyze $DB_NAME codeql/javascript-queries:codeql-suites/javascript-security-and-quality.qls --format=sarif-latest --output=results.sarif

echo "Analysis complete. Results saved to results.sarif"
#!/bin/bash

# Create database
echo "Creating database..."
codeql database create my-database --language=javascript --overwrite

# Run analysis
echo "Running CodeQL analysis..."
codeql database analyze my-database \
    codeql/javascript-queries:codeql-suites/javascript-security-and-quality.qls \
    --format=csv \
    --output=results.csv

echo "Analysis complete. Results saved to results.csv"
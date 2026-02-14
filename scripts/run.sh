#!/bin/bash

# CodeQL Version (The thing that use specific version in a single command as you asked for)
VERSIONS=(
    "/opt/codeql-2.22/codeql"
    "/opt/codeql-2.23/codeql"
    "/opt/codeql-2.24/codeql"
)

# Navigate to the juice-shop directory
cd /src/juice-shop || { echo "juice-shop directory not found! Please run clone.sh first."; exit 1; }

for CODEQL_BIN in "${VERSIONS[@]}"; do
    # Extract version name
    VERSION_NAME=$(basename $(dirname $CODEQL_BIN))

    echo "-------------------------------"
    echo "Running CodeQL analysis with version: $VERSION_NAME"
    $CODEQL_BIN version

    # Create db
    DB_NAME="../db-$VERSION_NAME"
    $CODEQL_BIN database create "$DB_NAME" --language=javascript --overwrite

    # Run analysis
    echo "Running CodeQL analysis for version: $VERSION_NAME"
    $CODEQL_BIN database analyze "$DB_NAME" --format=csv --output="../results-$VERSION_NAME.csv"

done

echo "All analyses completed. Results saved as results-<version>.csv"
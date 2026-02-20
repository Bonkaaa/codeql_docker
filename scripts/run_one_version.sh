#!/bin/bash

# Bash script to test 1 version of CodeQL, as you asked for. This is a simplified version of run.sh that only runs one version of CodeQL.

VERSIONS=(
    "/opt/codeql-2.22/codeql"
)

cd /src/juice-shop || { echo "juice-shop directory not found! Please run clone.sh first."; exit 1; }

# npm install (Not needed, maybe ???)

VERSION_NAME=$(basename $(dirname ${VERSIONS[0]}))
DB_NAME="../db-$VERSION_NAME"
${VERSIONS[0]} database finalize "$DB_NAME"

# Run analysis
echo "Running CodeQL analysis for version: $VERSION_NAME"
${VERSIONS[0]} database analyze "$DB_NAME" --format=csv --output="../results-$VERSION_NAME.csv"

echo "All analyses completed. Results saved as results-<version>.csv"
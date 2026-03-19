#!/bin/bash

mkdir -p results

pushd prototype-pollution-2.0

# Create db
if [ -d "/app/results/prototype-pollution-2.0" ]; then
    echo "Skip"
else
    echo "Create database"
    /app/codeqls/codeql-2.24.0/codeql database create "/app/results/prototype-pollution-2.0" --language=javascript --overwrite
    /app/codeqls/codeql-2.24.0/codeql database finalize "/app/results/prototype-pollution-2.0"
fi
# Run query
echo "Run query"

/app/codeqls/codeql-2.24.0/codeql database analyze \
  /app/results/prototype-pollution-2.0 \
  --format=csv \
  --output=/app/results/prototype-pollution-2.0.csv \
  --threads=2 \
  --ram=12000

popd
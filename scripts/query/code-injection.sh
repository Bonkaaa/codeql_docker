#!/bin/bash

mkdir -p results

pushd repos/code-injection

# Create db
if [ -d "/app/results/code-injection" ]; then
    echo "Skip"
else
    echo "Create database"
    /app/codeqls/codeql-2.22.0/codeql database create "/app/results/code-injection" --language=javascript --overwrite
    /app/codeqls/codeql-2.22.0/codeql database finalize "/app/results/code-injection"
fi
# Run query
echo "Run query"

/app/codeqls/codeql-2.22.0/codeql query run \
  /app/query/code_injection.ql \
  --database=/app/results/code-injection \
  --output=/app/results/code-injection.bqrs

/app/codeqls/codeql-2.22.0/codeql bqrs decode \
  /app/results/code-injection.bqrs \
  --format=csv \
  --output=/app/results/code-injection.csv 

# Rename CSV header (first row)
echo "Rename CSV header"

header='primary,source_node,sink_node,message,sink_file,sink_start_line,sink_end_line,source_file,source_start_line,source_end_line'

tmp="$(mktemp)"
{
  echo "$header"
  tail -n +2 /app/results/code-injection.csv
} > "$tmp"
mv "$tmp" /app/results/code-injection.csv

echo "Done. Results are in /app/results/code-injection.csv"

popd
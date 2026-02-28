#!/bin/bash

mkdir -p results

pushd repos/path-traversal

# Create db
if [ -d "/app/results/path-traversal" ]; then
    echo "Skip"
else
    echo "Create database"
    /app/codeqls/codeql-2.22.0/codeql database create "/app/results/path-traversal" --language=javascript --overwrite
    /app/codeqls/codeql-2.22.0/codeql database finalize "/app/results/path-traversal"
fi
# Run query
echo "Run query"

/app/codeqls/codeql-2.22.0/codeql query run \
  /app/query/path_traversal.ql \
  --database=/app/results/path-traversal \
  --output=/app/results/path-traversal.bqrs

/app/codeqls/codeql-2.22.0/codeql bqrs decode \
  /app/results/path-traversal.bqrs \
  --format=csv \
  --output=/app/results/path-traversal.csv \

header='primary,source_node,sink_node,message,sink_file,sink_start_line,sink_end_line,source_file,source_start_line,source_end_line'

tmp="$(mktemp)"
{
  echo "$header"
  tail -n +2 /app/results/path-traversal.csv
} > "$tmp"
mv "$tmp" /app/results/path-traversal.csv

chmod 644 /app/results/path-traversal.csv

echo "Done. Results are in /app/results/path-traversal.csv"

popd
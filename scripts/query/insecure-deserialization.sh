#!/bin/bash

mkdir -p results

pushd repos/insecure-deserialization

# Create db
if [ -d "/app/results/insecure-deserialization" ]; then
    echo "Skip"
else
    echo "Create database"
    /app/codeqls/codeql-2.22.0/codeql database create "/app/results/insecure-deserialization" --language=javascript --overwrite
    /app/codeqls/codeql-2.22.0/codeql database finalize "/app/results/insecure-deserialization"
fi
# Run query
echo "Run query"

/app/codeqls/codeql-2.22.0/codeql query run \
  /app/query/insecure_deserialization.ql \
  --database=/app/results/insecure-deserialization \
  --output=/app/results/insecure-deserialization.bqrs

/app/codeqls/codeql-2.22.0/codeql bqrs decode \
  /app/results/insecure-deserialization.bqrs \
  --format=csv \
  --output=/app/results/insecure-deserialization.csv

header='primary,source_node,sink_node,message,sink_file,sink_start_line,sink_end_line,source_file,source_start_line,source_end_line'

tmp="$(mktemp)"
{
  echo "$header"
  tail -n +2 /app/results/insecure-deserialization.csv
} > "$tmp"
mv "$tmp" /app/results/insecure-deserialization.csv

chmod 644 /app/results/insecure-deserialization.csv

echo "Done. Results are in /app/results/insecure-deserialization.csv"

popd
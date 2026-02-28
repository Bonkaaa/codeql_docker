#!/bin/bash

mkdir -p results

pushd repos/prototype-pollution

# Create db
if [ -d "/app/results/prototype-pollution" ]; then
    echo "Skip"
else
    echo "Create database"
    /app/codeqls/codeql-2.22.0/codeql database create "/app/results/prototype-pollution" --language=javascript --overwrite
    /app/codeqls/codeql-2.22.0/codeql database finalize "/app/results/prototype-pollution"
fi
# Run query
echo "Run query"

/app/codeqls/codeql-2.22.0/codeql query run \
  /app/query/prototype_pollution.ql \
  --database=/app/results/prototype-pollution \
  --output=/app/results/prototype-pollution.bqrs

/app/codeqls/codeql-2.22.0/codeql bqrs decode \
  /app/results/prototype-pollution.bqrs \
  --format=csv \
  --output=/app/results/prototype-pollution.csv \

header='primary,source_node,sink_node,message,sink_file,sink_start_line,sink_end_line,source_file,source_start_line,source_end_line'

tmp="$(mktemp)"
{
  echo "$header"
  tail -n +2 /app/results/prototype-pollution.csv
} > "$tmp"
mv "$tmp" /app/results/prototype-pollution.csv

chmod 644 /app/results/prototype-pollution.csv

echo "Done. Results are in /app/results/prototype-pollution.csv"

popd
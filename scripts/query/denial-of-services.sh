#!/bin/bash

mkdir -p results

pushd repos/denial-of-services

# Create db
if [ -d "/app/results/denial-of-services" ]; then
    echo "Skip"
else
    echo "Create database"
    /app/codeqls/codeql-2.22.0/codeql database create "/app/results/denial-of-services" --language=javascript --overwrite
    /app/codeqls/codeql-2.22.0/codeql database finalize "/app/results/denial-of-services"
fi
# Run query
echo "Run query"

/app/codeqls/codeql-2.22.0/codeql query run \
  /app/query/denial_of_services.ql \
  --database=/app/results/denial-of-services \
  --output=/app/results/denial-of-services.bqrs

/app/codeqls/codeql-2.22.0/codeql bqrs decode \
  /app/results/denial-of-services.bqrs \
  --format=csv \
  --output=/app/results/denial-of-services.csv \

header='primary,source_node,sink_node,message,sink_file,sink_start_line,sink_end_line,source_file,source_start_line,source_end_line'

tmp="$(mktemp)"
{
  echo "$header"
  tail -n +2 /app/results/denial-of-services.csv
} > "$tmp"
mv "$tmp" /app/results/denial-of-services.csv

chmod 644 /app/results/denial-of-services.csv

echo "Done. Results are in /app/results/denial-of-services.csv"

popd
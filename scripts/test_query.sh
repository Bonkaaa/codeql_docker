#!/bin/bash

mkdir -p results

pushd repos/juice-shop

# Create db
if [-d "/app/results/codeql-2.22"]; then
    echo "Skip"
else
    echo "Create db"
    /app/codeqls/codeql-2.22.0/codeql database create "/app/results/codeql-2.22" --language=javascript --overwrite
    /app/codeqls/codeql-2.22.0/codeql database finalize "/app/results/codeql-2.22"
fi
# Run query
echo "Run query"

/app/codeqls/codeql-2.22.0/codeql query run \
  /app/query/zip_query.ql \
  --database=/app/results/codeql-2.22 \
  --output=/app/results/codeql-2.22.bqrs

# /app/codeqls/codeql-2.22.0/codeql query run \
#   /app/query/code_injection.ql \
#   --database=/app/results/codeql-2.22 \
#   --output=/app/results/codeql-2.22.bqrs

# /app/codeqls/codeql-2.22.0/codeql query run \
#   /app/query/command_injection.ql \
#   --database=/app/results/codeql-2.22 \
#   --output=/app/results/codeql-2.22.bqrs

# /app/codeqls/codeql-2.22.0/codeql query run \
#   /app/query/denial_of_services.ql \
#   --database=/app/results/codeql-2.22 \
#   --output=/app/results/codeql-2.22.bqrs

# /app/codeqls/codeql-2.22.0/codeql query run \
#   /app/query/insecure_deserialization.ql \
#   --database=/app/results/codeql-2.22 \
#   --output=/app/results/codeql-2.22.bqrs

# /app/codeqls/codeql-2.22.0/codeql query run \
#   /app/query/prototype_polluting.ql \
#   --database=/app/results/codeql-2.22 \
#   --output=/app/results/codeql-2.22.bqrs

popd
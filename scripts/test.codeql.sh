#!/bin/bash

mkdir -p results

pushd repos/juice-shop
/app/codeqls/codeql-2.22.0/codeql database create "/app/results/codeql-2.22" --language=javascript --overwrite
/app/codeqls/codeql-2.22.0/codeql database finalize "/app/results/codeql-2.22"
/app/codeqls/codeql-2.22.0/codeql database analyze "/app/results/codeql-2.22" --format=csv --output="/app/results/codeql-2.22.csv"
popd
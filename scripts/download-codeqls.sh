#!/bin/bash

# Download and extract CodeQL versions
versions=("2.22.0" "2.23.0" "2.24.0")

# mkdir -p "./codeqls"

# for version in "${versions[@]}"; do
#     wget "https://github.com/github/codeql-action/releases/download/codeql-bundle-v${version}/codeql-bundle-linux64.tar.gz" -O "${version}.tar.gz"
#     mkdir -p "./codeqls/codeql-${version}"
#     tar -xzf "${version}.tar.gz" -C "./codeqls/codeql-${version}" --strip-components=1
#     rm "${version}.tar.gz"
# done

wget "https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.24.0/codeql-bundle-linux64.tar.gz" -O "2.24.0.tar.gz"
    mkdir -p "./codeqls/codeql-2.24.0"
    tar -xzf "2.24.0.tar.gz" -C "./codeqls/codeql-2.24.0" --strip-components=1
    rm "2.24.0.tar.gz"

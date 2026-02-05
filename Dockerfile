# Lightweight linux
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget git unzip python3 python3-venv && \
    apt-get clean

# Set working dir for tools
WORKDIR /opt

# Argument for CodeQL version
ARG CODEQL_VERSION

# Download CodeQL bundle
RUN wget https://github.com/github/codeql-action/releases/download/${CODEQL_VERSION}/codeql-bundle-linux64.tar.gz -O codeql.tar.gz && \
    tar -xzf codeql.tar.gz && \
    rm codeql.tar.gz

# Add CodeQL to PATH
ENV PATH="/opt/codeql:${PATH}"

# Set working dir for analysis
WORKDIR /src


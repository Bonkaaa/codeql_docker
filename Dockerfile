# Lightweight linux
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget git unzip python3 python3-venv && \
    apt-get clean

# Set working dir for tools
WORKDIR /opt

# Download CodeQL bundle
RUN wget https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.16.0/codeql-bundle-linux64.tar.gz -O codeql.tar.gz && \
    tar -xzf codeql.tar.gz && \
    rm codeql.tar.gz

# Add CodeQL to PATH
ENV PATH="/opt/codeql:${PATH}"

# Set working dir for analysis
WORKDIR /src


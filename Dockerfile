# Lightweight linux
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget git unzip python3 python3-venv && \
    apt-get clean

# Set working dir for tools
WORKDIR /opt

# Download and extract CodeQL version (Can change to desired version)
RUN wget https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.22.0/codeql-bundle-linux64.tar.gz -O 2.22.tar.gz && \
    mkdir -p /opt/codeql-2.22 && \
    tar -xzf 2.22.tar.gz -C /opt/codeql-2.22 --strip-components=1 && \
    rm 2.22.tar.gz

RUN wget https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.23.0/codeql-bundle-linux64.tar.gz -O 2.23.tar.gz && \
    mkdir -p /opt/codeql-2.23 && \
    tar -xzf 2.23.tar.gz -C /opt/codeql-2.23 --strip-components=1 && \
    rm 2.23.tar.gz

RUN wget https://github.com/github/codeql-action/releases/download/codeql-bundle-v2.24.0/codeql-bundle-linux64.tar.gz -O 2.24.tar.gz && \
    mkdir -p /opt/codeql-2.24 && \
    tar -xzf 2.24.tar.gz -C /opt/codeql-2.24 --strip-components=1 && \
    rm 2.24.tar.gz

# Set working dir for analysis
WORKDIR /src


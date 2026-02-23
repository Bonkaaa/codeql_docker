# Lightweight linux
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget git unzip nodejs npm python3 python3-pip && \
    apt-get clean
#!/bin/bash

# Build Docker image for CodeQL analysis
echo "Building Docker image for CodeQL analysis..."
docker build -t codeql-analysis-image .

# Run Docker container
echo "Running Docker container for CodeQL analysis..."
docker run --rm -it -v ${PWD}:/src codeql-analysis-image bash

echo "Docker container has been built and run successfully."
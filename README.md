<!-- 1. `docker compose up -d`
2. `docker exec -it codeqls-container /bin/bash` -->
# CodeQL Docker
This is the tool used for running CodeQL in a Docker container. It is based on the official CodeQL Docker image, but it also includes some additional tools and scripts for easier usage.

## Setup
```bash
# 1. Start container
docker compose up -d

# 2. Access container
docker exec -it codeqls-container /bin/bash

# 3. Download CodeQL bundle
bash scripts/download-codeqls.sh

# 4. Clone repo
bash scripts/test.clone.sh
```

## Usage
```bash
# Two options for running CodeQL queries:

# 1. Run a single query
# For example
bash scripts/query/code-injection.sh

# 2. Run test analysis
bash scripts/test.codeql.sh
```

## Directory structures
```
codeqls/                                # Code bundle
├── codeql-XXX (XXX means version)      # CVE database
├── ...          
               # Output

query/
├── code-injection.ql                   # CodeQL query for code injection
├── ...                                 # Other queries

repos/                                  # Repositories to analyze
├── code-injection                      
├── command-injection  
├── denial-of-services
├── insecure-deserialization
├── path-traversal
├── prototype-pollution

results/                                # Results folder and database built from CodeQL
├── code-injection                      # Database
├── code-injection.bqrs                 # Binary results from running the query
├── code-injection.csv                  # Csv results from decoding the bqrs file
├── ...

scripts/
├── download-codeqls.sh                 # Script for downloading CodeQL bundle
├── test.clone.sh                       # Script for cloning repositories to analyze
├── test.codeql.sh                      # Script for running CodeQL analysis on the cloned repositories
└── query/                              # Query running scripts
    ├── code-injection.sh           
    └── ...
```

## Requirements
- Docker & Docker Compose
- Git

## Notes
- The `scripts` directory contains various scripts for setting up and running CodeQL. You can modify these scripts to suit your needs or add new ones for different queries or analyses.
- The `queries` directory contains the actual CodeQL queries that you can run. You can add your own queries here or modify the existing ones.
- Make sure to have the necessary permissions and configurations for running Docker and accessing the container.


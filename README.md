1. `docker compose up -d`
2. `docker exec -it codeqls-container /bin/bash`

### Inside docker
Cmd for decode result (As result would be in binary BQRS foramt):
`{codeql-version}  {path_to_result_file}.csv   --format=csv   --output={path_to_decode_file}.csv`
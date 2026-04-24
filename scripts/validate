#!/bin/sh
# This script uses yamllint and ajv to validate a YAML file against a provided JSON schema.
# It supports multi-document YAML files by validating each YAML document separately.
#
# Usage: ./scripts/validate schema.json <file.yml>
#
# Required tools: yamllint, ajv-cli, ajv-formats

set -e

if [ "$#" -ne 2 ]; then
  cat <<'EOF' >&2
Usage: $0 <schema.json> <file.yml>
Validates YAML syntax with yamllint and validates each YAML document with ajv.
EOF
  exit 1
fi

schema=$1
file=$2

echo "# ---------------------------------"
echo "# $file YAML syntax..."

echo "# Checking yaml format for $file:"
yamllint -d "{extends: default,  rules: {document-start: disable, empty-lines: disable, trailing-spaces: disable, line-length: {max: 2000}}}" "$file"

echo "# Checking file validity against schema $schema:"

python3 <<'PY'
import json
import shlex
import subprocess
import sys
import yaml

schema = sys.argv[1]
file_path = sys.argv[2]

with open(file_path, 'r', encoding='utf-8') as f:
    docs = list(yaml.safe_load_all(f))

if not docs:
    print(f"No documents found in {file_path}", file=sys.stderr)
    sys.exit(1)

for index, doc in enumerate(docs, start=1):
    if doc is None:
        print(f"# Skipping empty document {index}/{len(docs)}")
        continue

    print(f"# Validating document {index}/{len(docs)}...")
    process = subprocess.run(
        [
            'ajv',
            '-c', 'ajv-formats',
            '--verbose',
            '--coerce-types=array',
            '--remove-additional=true',
            '--changes',
            '-s', schema,
            '-d', '-',
        ],
        input=json.dumps(doc).encode('utf-8'),
        stdout=sys.stdout,
        stderr=sys.stderr,
    )

    if process.returncode != 0:
        sys.exit(process.returncode)
PY

#!/bin/bash

# Define the path to the JSON schema, relative to this script's location.
# Assuming schema.json is in the repository root.
SCHEMA="$(dirname "$(realpath "$0")")/../schema.json"

# --- Dependency Checks ---
# Check if ajv-cli is installed
if ! command -v ajv &> /dev/null; then
    echo "Error: 'ajv' command not found."
    echo "Please install ajv-cli globally: npm install -g ajv-cli"
    exit 1
fi
# --- End Dependency Checks ---

# Check if a YAML file was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_yaml_file>"
    echo "Example: $0 Pisum/sativum/studies/pissa.Sato_Morita_2007.yml"
    echo ""
    echo "NOTE: This script only works on yaml files that contain a single yaml document."
    echo "NOTE: If your file has multiple yaml documents (separated by '---'), use validate_gfr.sh instead."
    echo ""
    exit 1
fi

YML_FILE="$1"

# Check if the provided file exists
if [ ! -f "$YML_FILE" ]; then
    echo "Error: YAML file not found: $YML_FILE"
    exit 1
fi

echo "--- Validating Single YAML File ---"
echo "File:   $YML_FILE"
echo "Schema: $SCHEMA"
echo "-----------------------------------"

# Validate the YAML file directly using ajv.
# ajv will use its internal YAML parser to process the file.
ajv validate -s "$SCHEMA" -d "$YML_FILE"
AJV_EXIT_CODE=$?

if [ $AJV_EXIT_CODE -ne 0 ]; then
    echo "Validation FAILED for $YML_FILE"
    exit 1
else
    echo "Validation PASSED for $YML_FILE"
    exit 0
fi

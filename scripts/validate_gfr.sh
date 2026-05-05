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

# Check if yq (Mike Farrah's Go version 3+) is installed
if ! command -v yq &> /dev/null || ! yq --version 2>&1 | grep -q 'version v[3-9]\.'; then
    echo "Error: 'yq' (Mike Farrah's Go version 3+) command not found or is an incompatible version."
    echo "Please install it from https://github.com/mikefarah/yq#install"
    echo "Example: wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq"
    exit 1
fi
# --- End Dependency Checks ---

# Check if a YAML file was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_yaml_file>"
    echo "Example: $0 Pisum/sativum/studies/pissa.Feng_Chen_2024.yml"
    exit 1
fi

YML_FILE="$1"

# Check if the provided file exists
if [ ! -f "$YML_FILE" ]; then
    echo "Error: YAML file not found: $YML_FILE"
    exit 1
fi

TOTAL_DOCUMENTS_VALIDATED=0
TOTAL_DOCUMENTS_FAILED=0
FILE_HAS_ERRORS=false

echo "==============================================="
echo "File:   $YML_FILE"
#echo "Schema: $SCHEMA"

# --- Get the number of documents in the YAML file ---
# We use 'eval-all . | ""' to process each document and output an empty string,
# then 'wc -l' to count the lines, which corresponds to the number of documents.
NUM_DOCS=$(yq eval-all '. | ""' "$YML_FILE" 2>/dev/null | wc -l)
if [ $? -ne 0 ]; then
    echo "Error: Could not determine number of documents in $YML_FILE using yq. Please check file format."
    exit 1
fi

if [ "$NUM_DOCS" -eq 0 ]; then
    echo "Warning: No YAML documents found in $YML_FILE. Nothing to validate."
    exit 0
fi

# Loop through each document by index
for (( i=0; i<NUM_DOCS; i++ )); do
    CURRENT_DOC_INDEX=$((i + 1))
    TOTAL_DOCUMENTS_VALIDATED=$((TOTAL_DOCUMENTS_VALIDATED + 1))
    
    echo "  - Validating document $CURRENT_DOC_INDEX ..."
    
    # Create a temporary file for the current YAML document. This works on both MacOS and Linux
    export TMPDIR="${TMPDIR:-/tmp}"
    TEMP_DOC_FILE=$(mktemp -p "$TMPDIR")
    TEMP_DOC_FILE="${TEMP_DOC_FILE}.yml"
    
    # Extract the specific YAML document using yq and save it to the temporary file
    # 'select(document_index == $i)' extracts the document at index i (0-based)
    if ! yq e "select(document_index == $i)" "$YML_FILE" > "$TEMP_DOC_FILE"; then
        echo "    Error: Failed to extract document $CURRENT_DOC_INDEX from $YML_FILE using yq. Skipping validation for this document."
        FILE_HAS_ERRORS=true
        TOTAL_DOCUMENTS_FAILED=$((TOTAL_DOCUMENTS_FAILED + 1))
        rm -f "$TEMP_DOC_FILE"
        continue
    fi
    
    # Validate the temporary YAML file using ajv
    ajv validate -s "$SCHEMA" -d "$TEMP_DOC_FILE"
    AJV_EXIT_CODE=$?
    
    # Clean up the temporary file
    rm -f "$TEMP_DOC_FILE"
    
    if [ $AJV_EXIT_CODE -ne 0 ]; then
        echo "    --> Validation FAILED for document $CURRENT_DOC_INDEX"
        FILE_HAS_ERRORS=true
        TOTAL_DOCUMENTS_FAILED=$((TOTAL_DOCUMENTS_FAILED + 1))
    else
        echo "    --> Validation PASSED for document $CURRENT_DOC_INDEX"
    fi
done

echo ""
echo "--- Validation Summary for $YML_FILE ---"
echo "Total documents validated:  $TOTAL_DOCUMENTS_VALIDATED"
echo "Total documents failed:     $TOTAL_DOCUMENTS_FAILED"

if [ "$FILE_HAS_ERRORS" = true ]; then
    echo "Overall Validation: FAILED (Some documents contain errors)."
    echo ""
    exit 1
else
    echo "Overall Validation: PASSED (All documents are valid)."
    echo ""
    exit 0
fi

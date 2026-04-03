#!/usr/bin/env bash

# This script traverses the directory tree in gene-function-registry repository to find all paths with 'studies',
# extracts genus and species names from the path, creates a 'gensp' identifier,
# and then performs text extraction and analysis on files within each 'studies' directory.
# It processes 'entity' and 'entity_name' as pairs from YAML files.

# --- Check for yq installation ---
if ! command -v yq &> /dev/null; then
    echo "Error: 'yq' command not found."
    echo "The 'yq' tool is required to parse YAML files for entity pairs."
    echo "Please install yq, e.g., 'brew install yq' on macOS,"
    echo "or on ceres.scinet.usda.gov, activate the 'ds-curate' conda environment."
    exit 1
fi

# --- Function to process single-key data from YAML files (e.g., gene_model_full_id) ---
# Arguments:
#   $1: The gensp string, e.g., "glyma"
#   $2: The search string, e.g., "gene_model_full_id"
#   $3: The path to the 'studies' directory
#   $4: Optional output file prefix for saving results
process_single_key_data() {
    local gensp="$1"
    local search_string="$2"
    local studies_dir="$3"
    local output_file="$4"

    if [ "$PRINT" = true ]; then
        echo "  Summary for $gensp, key: '$search_string'" >> "$output_file"
        echo "  --------------------------------------------------" >> "$output_file"
    else
        echo "  Summary for $gensp, key: '$search_string'"
        echo "  --------------------------------------------------"
    fi

    local yaml_files=()
    # Find all YAML files directly within the 'studies' directory
    while IFS= read -r -d $'\0' file; do
        yaml_files+=("$file")
    done < <(find "$studies_dir" -maxdepth 1 -type f -name "*.yml" -print0)

    if [ ${#yaml_files[@]} -eq 0 ]; then
        echo "    No YAML files found in '$studies_dir' to process for '$search_string'."
        return 0 # Exit function gracefully
    fi

    local result_output
    result_output=$(
        # Use awk to find lines containing the search_string in all relevant YAML files
        # Then use cut -d ":" -f 2 to get the value after the first colon
        # and sed to remove leading whitespace.
        awk -v s="$search_string" '$0 ~ s { print $0 }' "${yaml_files[@]}" 2>/dev/null | \
          cut -d ":" -f 2 | sed 's/^[[:space:]]*//' | sort | uniq -c | sort -nr
    )

    if [ -n "$result_output" ]; then
        # Optional: Save the output to a file if '-p', else print to STDOUT
        if [ "$PRINT" = true ]; then
            echo "$result_output" >> "$output_file"
            echo "  --------------------------------------------------" >> "$output_file"
            echo "">> "$output_file"
        else
            echo "$result_output"
            echo "  --------------------------------------------------"
            echo ""
        fi
    else
        echo "    No relevant data found for '$search_string'."
    fi
}

# --- Function to process citation, doi, and pmid as a three-column table ---
# Arguments:
#   $1: The gensp string, e.g., "glyma"
#   $2: The path to the 'studies' directory
#   $3: Optional output file prefix for saving results
process_citation_table() {
    local gensp="$1"
    local studies_dir="$2"
    local output_file="$3"

    if [ "$PRINT" = true ]; then
        echo "  Citation, DOI, and PMID Summary for $gensp" >> "$output_file"
        echo "  --------------------------------------------------" >> "$output_file"
    else
        echo "  Citation, DOI, and PMID Summary for $gensp"
        echo "  --------------------------------------------------"
    fi

    local yaml_files=()
    # Find all YAML files directly within the 'studies' directory
    while IFS= read -r -d $'\0' file; do
        yaml_files+=("$file")
    done < <(find "$studies_dir" -maxdepth 1 -type f -name "*.yml" -print0)

    if [ ${#yaml_files[@]} -eq 0 ]; then
        echo "    No YAML files found in '$studies_dir'."
        return 0
    fi

    local table_output
    table_output=$(
        for yml_file in "${yaml_files[@]}"; do
            # Extract citation, doi, and pmid from traits and format as pipe-separated
            yq '.traits[] | select(has("citation") and has("doi") and has("pmid")) | 
                .citation + " | " + (.doi // "N/A") + " | " + (.pmid // "N/A")' "$yml_file" 2>/dev/null
        done | sed '/---/d' | sort | uniq -c | sort -nr
    )

    if [ -n "$table_output" ]; then
        if [ "$PRINT" = true ]; then
            echo "Count | Citation | DOI | PMID" >> "$output_file"
            echo "  --------------------------------------------------" >> "$output_file"
            echo "$table_output" >> "$output_file"
            echo "  --------------------------------------------------" >> "$output_file"
            echo "" >> "$output_file"
        else
            echo "Count | Citation | DOI | PMID"
            echo "  --------------------------------------------------"
            echo "$table_output"
            echo "  --------------------------------------------------"
            echo ""
        fi
    else
        echo "    No records with citation, doi, and pmid found."
        if [ "$PRINT" = true ]; then
            echo "  --------------------------------------------------" >> "$output_file"
            echo "" >> "$output_file"
        else
            echo ""
        fi
    fi
}

# --- Function to process entity/entity_name pairs from YAML files ---
# Arguments:
#   $1: The gensp string, e.g., "glyma"
#   $2: The path to the 'studies' directory
#   $3: Optional output file prefix for saving results
process_entity_pairs() {
    local gensp="$1"
    local studies_dir="$2"
    local output_file="$3"

    local yaml_files=()
    # Find all YAML files directly within the 'studies' directory
    while IFS= read -r -d $'\0' file; do
        yaml_files+=("$file")
    done < <(find "$studies_dir" -maxdepth 1 -type f -name "*.yml" -print0)

    if [ ${#yaml_files[@]} -eq 0 ]; then
        echo "    No YAML files found in '$studies_dir' to process for entity pairs."
        return 0 # Exit function gracefully
    fi

    local combined_pairs_output
    # Use yq to extract and combine entity and entity_name for each trait
    combined_pairs_output=$(
        for yml_file in "${yaml_files[@]}"; do
            # Select entries in 'traits' array that have both 'entity' and 'entity_name'
            # and output them as "entity | entity_name"
            yq '.traits[] | select(has("entity") and has("entity_name")) | .entity + " | " + .entity_name' "$yml_file" 2>/dev/null
        done | sed '/---/d' | sort | uniq -c | sort -nr 
    )

    if [ -n "$combined_pairs_output" ]; then
        # Save the output to a file if '-p', else print to STDOUT
        if [ "$PRINT" = true ]; then
            echo "  Summary for $gensp, GO entities and descriptions ..." >> "$output_file"
            echo "  --------------------------------------------------" >> "$output_file"
            echo "$combined_pairs_output" >> "$output_file"
            echo "    Results saved to: $output_file"
            echo "  --------------------------------------------------" >> "$output_file"
            echo "" >> "$output_file"
        else    
            echo "  Summary for $gensp, GO entities and descriptions ..."
            echo "  --------------------------------------------------"
            echo "$combined_pairs_output"
            echo "$result_output"
            echo "  --------------------------------------------------"
            echo ""
        fi

    else
        echo "    No entity/entity_name pairs found."
    fi
}

# --- Main script logic ---
usage() {
    echo "Usage: $(basename "$0") [-h] [-p] PATH"
    echo "  -h for this usage message"
    echo "  -p to print to gensp.report.txt files in the respective Genus/species/gene_functions/ directories, OVERWRITING"
    echo "  -d to print to gensp.report.DATE.txt . Use this option with -p to generate files with a date string."
    echo "  argument 'PATH': the path to the Genus directories, e.g. $(basename "$0") -p ."
    echo ""
    echo "NOTE: Please don't generate gensp.report.DATE.txt to be checked into the repository."
    echo "Rather, update the existing gensp.report.txt files and use the git history to track changes."
    echo ""
    echo "Examples:"
    echo "  To print to STDOUT: "
    echo "     $(basename "$0") ."
    echo "  To print reports to each Genus/species/gene_functions/gensp.report.txt :"
    echo "     $(basename "$0") -p ."
    echo "  To print reports to each Genus/species/gene_functions/gensp.report.DATE.txt :"
    echo "     $(basename "$0") -p -d ."
    exit 1
}

while getopts ":pdh" opt; do
    case $opt in 
        p) PRINT=true ;;
        d) DATE=true ;;
        h) HELP=true ;;
        \?) echo "Invalid option -$OPTARG" 2>&1
           usage ;;
    esac
done

if [[ $# -eq 0 || "$HELP" == "true" ]] ; then
    usage
fi

if [[ "$DATE" == "true" ]] ; then
    DATE=$(date +%Y-%m-%d)
    if [[ -z $PRINT ]] ; then
        echo ""
        echo "If you wish to print to a file with a date string, specify both p and d flags: '-p -d'"
        echo ""
        echo "NOTE: Please don't generate gensp.report.DATE.txt to be checked into the repository."
        echo "Rather, update the existing gensp.report.txt files and use the git history to track changes."
        echo ""
        exit 1
    fi
fi

find . -type d -name studies | while IFS= read -r full_path; do
    # Remove the leading "./" from the path
    path_without_dot="${full_path#./}"

    # Validate the path structure
    if [[ "$path_without_dot" =~ ^[^/]+/[^/]+ ]]; then
        genus_name="${path_without_dot%%/*}"
        temp_path="${path_without_dot#*/}"
        species_name="${temp_path%%/*}"
        gensp_temp="${genus_name:0:3}${species_name:0:2}"
        gensp=$(echo "$gensp_temp" | tr '[:upper:]' '[:lower:]')

        # Filename for output file within this species directory 
        if [[ -n $DATE && $DATE != "true" ]]; then
            current_output_file="${genus_name}/${species_name}/gene_functions/${gensp}.report.${DATE}.txt"
        else
            current_output_file="${genus_name}/${species_name}/gene_functions/${gensp}.report.txt"
        fi
        if [ ! -d "${genus_name}/${species_name}/gene_functions/" ]; then
            echo "Directory 'gene_functions' doesn't exist at ./${genus_name}/${species_name} ."
            echo "The script should be called from the root directory of the gene-function-registry."
            usage 
            exit 1
        fi

        # Save the output to a file if '-p', else print to STDOUT
        if [ "$PRINT" = true ]; then
            echo "" > "$current_output_file" # NOTE: This overwrites any existing file at this location!
            echo "Status for $genus_name $species_name ($gensp) as of $(date +%Y-%m-%d):" >> "$current_output_file"
            echo "" >> "$current_output_file"
        else    
            echo "Status for $genus_name $species_name ($gensp) as of $(date +%Y-%m-%d):"
            echo ""
        fi

        # Process citation, doi, and pmid as a three-column table
        process_citation_table "$gensp" "$full_path" "$current_output_file"

        # Process gene_model_full_id as a single-key element
        process_single_key_data "$gensp" "gene_model_full_id" "$full_path" "$current_output_file"

        # Process for 'entity' and 'entity_name' as a pair using the new function
        process_entity_pairs "$gensp" "$full_path" "$current_output_file"

        # Save the output to a file if '-p', else print to STDOUT
        if [ "$PRINT" = true ]; then
            echo "======================================================================" >> "$current_output_file"
            echo "" >> "$current_output_file"
        else    
            echo "======================================================================"
            echo ""
        fi

    else
        echo "Skipping path '$full_path': Does not match the expected 'Level1/Level2/studies' structure."
        echo "--------------------------------------------------------------------------------"
        echo ""
    fi

done

echo "Directory traversal and data extraction completed."


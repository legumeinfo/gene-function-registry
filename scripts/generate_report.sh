#!/usr/bin/env bash

# This script traverses the directory tree in gene-function-registry to find all paths with 'studies',
# extracts genus and species names from the path, creates a 'gensp' identifier,
# and then performs text extraction and analysis on files within each 'studies' directory.
# It processes 'entity' and 'entity_name' as pairs from YAML files.

# --- Check for yq installation ---
if ! command -v yq &> /dev/null; then
    echo "Error: 'yq' command not found."
    echo "The 'yq' tool is required to parse YAML files for entity pairs."
    echo "Please install yq, e.g., 'brew install yq' on macOS,"
    echo "or on ceres.scinet.usda.gov, activate the 'ds-curate' conda environment."
    echo "In GitHub codespaces, yq should be installed by postCreateCommand in the devcontainer."
    exit 1
fi

# --- Function to process all gene_symbols in YAML files ---
# Arguments:
#   $1: The gensp string, e.g., "glyma"
#   $2: The path to the 'studies' directory
#   $3: Optional output file prefix for saving results
process_gene_symbols() {
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
        return 0
    fi

    # Use yq to extract and combine gene symbols
    local gene_symbols_output
    gene_symbols_output=$(
        for yml_file in "${yaml_files[@]}"; do
            yq '.gene_symbols[]' "$yml_file" 2>/dev/null
        done | sed '/---/d' | sort | uniq -c | sort -nr | perl -pe 's/^( +\d+) /$1\t/'
    )

    # Save the output to a file if '-p', else print to STDOUT
    if [ "$PRINT" = true ]; then
        ( echo "Count  gene_symbols; Summary for $gensp"
          echo "  --------------------------------------------------" 
          echo "$gene_symbols_output" >> "$output_file"
          echo "  --------------------------------------------------" 
          echo "" ) >> "$output_file"
    else    
        echo "Count  gene_symbols; Summary for $gensp"
        echo "  --------------------------------------------------" 
        echo "$gene_symbols_output"
        echo "  --------------------------------------------------"
        echo ""
    fi
}

# --- Function to process gene_model_full_id in YAML files ---
# Arguments:
#   $1: The gensp string, e.g., "glyma"
#   $2: The path to the 'studies' directory
#   $3: Optional output file prefix for saving results
process_gene_model_full_id() {
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
        return 0
    fi

    # Use yq to extract and combine gene_model_full_id
    local gene_id_output
    gene_id_output=$(
        for yml_file in "${yaml_files[@]}"; do
            yq '.gene_model_full_id' "$yml_file" 2>/dev/null
        done | sed '/---/d' | sort | uniq -c | sort -nr | perl -pe 's/^( +\d+) /$1\t/'
    )

    # Save the output to a file if '-p', else print to STDOUT
    if [ "$PRINT" = true ]; then
        ( echo "Count  gene_model_full_id; Summary for $gensp"
          echo "  --------------------------------------------------" 
          echo "$gene_id_output" >> "$output_file"
          echo "  --------------------------------------------------" 
          echo "" ) >> "$output_file"
    else    
        echo "Count  gene_model_full_id; Summary for $gensp"
        echo "  --------------------------------------------------" 
        echo "$gene_id_output"
        echo "  --------------------------------------------------"
        echo ""
    fi
}

# --- Function to process first gene_symbol and gene_model_full_id in YAML files ---
# Arguments:
#   $1: The gensp string, e.g., "glyma"
#   $2: The path to the 'studies' directory
#   $3: Optional output file prefix for saving results
process_gene_symbol_and_gene_model() {
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
        return 0
    fi

    # Use yq to extract and combine gene symbol and gene IDfor each trait
    local gene_symbol_and_id_output
    gene_symbol_and_id_output=$(
        for yml_file in "${yaml_files[@]}"; do
            yq '.gene_symbols[0] + "\t" + .gene_model_full_id' "$yml_file" 2>/dev/null
        done | sed '/---/d' | sort | uniq -c | sort -nr | perl -pe 's/^( +\d+) /$1\t/'
    )

    # Save the output to a file if '-p', else print to STDOUT
    if [ "$PRINT" = true ]; then
        ( echo "Count  Primary symbol   gene_model_full_id ; Summary for $gensp"
          echo "  --------------------------------------------------" 
          echo "$gene_symbol_and_id_output" >> "$output_file"
          echo "  --------------------------------------------------" 
          echo "" ) >> "$output_file"
    else    
        echo "Count  Primary symbol   gene_model_full_id ; Summary for $gensp"
        echo "  --------------------------------------------------" 
        echo "$gene_symbol_and_id_output"
        echo "  --------------------------------------------------"
        echo ""
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
            # Extract citation, doi, and pmid from references and format as pipe-separated
            yq '.references[] | select(has("citation") and has("doi") and has("pmid")) | 
                (.pmid // "N/A") + "\t" + (.doi // "N/A") + "\t" + .citation' "$yml_file" 2>/dev/null
        done | sed '/---/d' | sort | uniq -c | sort -nr | perl -pe 's/^( +\d+) /$1\t/'
    )

    if [ -n "$table_output" ]; then
        if [ "$PRINT" = true ]; then
            ( echo "Count  PMID   DOI   Citation; Summary for $gensp" >> "$output_file"
              echo "  --------------------------------------------------" 
              echo "$table_output" >> "$output_file"
              echo "  --------------------------------------------------" 
              echo "" ) >> "$output_file"
        else
            echo "Count  PMID   DOI   Citation; Summary for $gensp"
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
        return 0
    fi

    local combined_pairs_output
    # Use yq to extract and combine entity and entity_name for each trait
    combined_pairs_output=$(
        for yml_file in "${yaml_files[@]}"; do
            # Select entries in 'traits' array that have both 'entity' and 'entity_name'
            # and output them as "entity | entity_name"
            yq '.traits[] | select(has("entity") and has("entity_name")) | .entity + "\t" + .entity_name' "$yml_file" 2>/dev/null
        done | sed '/---/d' | sort | uniq -c | sort -nr | perl -pe 's/^( +\d+) /$1\t/'
    )

    if [ -n "$combined_pairs_output" ]; then
        # Save the output to a file if '-p', else print to STDOUT
        if [ "$PRINT" = true ]; then
            ( echo "Count  Ontology accession   Description; Summary for $gensp"
              echo "  --------------------------------------------------" 
              echo "$combined_pairs_output" >> "$output_file"
              echo "  --------------------------------------------------" 
              echo "" ) >> "$output_file"
        else    
            echo "Count  Ontology accession   Description; Summary for $gensp"
            echo "  --------------------------------------------------" 
            echo "$combined_pairs_output"
            echo "  --------------------------------------------------"
            echo ""
        fi

    else
        echo "    No entity/entity_name pairs found."
    fi
}

# --- Main script logic ---
usage() {
    echo "Usage: $(basename "$0 [Genus] [species]") [-h] [-p] [-d]"
    echo "  -h for this usage message"
    echo "  -p to print to gensp.report.txt files in the respective Genus/species/gene_functions/ directories, OVERWRITING"
    echo "  -d to print to gensp.report.DATE.txt . Use this option with -p to generate files with a date string."
    echo ""
    echo "NOTE: Please don't generate gensp.report.DATE.txt to be checked into the repository."
    echo "Rather, update the existing gensp.report.txt files and use the git history to track changes."
    echo ""
    echo "Examples:"
    echo "  To print to STDOUT: "
    echo "     scripts/$(basename "$0") Glycine max"
    echo "  To print reports to each Genus/species/gene_functions/gensp.report.txt :"
    echo "     scripts/$(basename "$0") -p Glycine max"
    echo "  To print reports to each Genus/species/gene_functions/gensp.report.DATE.txt :"
    echo "     scripts/$(basename "$0") -p -d Glycine max"
    echo "  To generate reports for all species:"
    echo "     cat templates/genus_species.tsv | while read -r line; do"
    echo "       genus=\$(echo \$line | cut -f1 -d' ')" 
    echo "       species=\$(echo \$line | cut -f2 -d' ')"
    echo "       echo \$genus \$species"
    echo "       scripts/generate_report.sh -p \$genus \$species"
    echo "     done"
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

if [[ "$HELP" == "true" ]] ; then
    usage
    exit 1
fi

shift $((OPTIND -1))

genus_name="$1"
species_name="$2"

# Check if two positional arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    usage
    exit 1
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

# Generate gensp string and then call functions for all sub-reports
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
    usage & exit 1
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

full_path="${genus_name}/${species_name}/studies"

# Process gene_symbols (all; primary and other)
process_gene_symbols "$gensp" "$full_path" "$current_output_file"

# Process gene_model_full_ids 
process_gene_model_full_id "$gensp" "$full_path" "$current_output_file"

# Process gene_symbol and gene_model_full_id as a two-column table
process_gene_symbol_and_gene_model "$gensp" "$full_path" "$current_output_file"

# Process citation, doi, and pmid as a three-column table
process_citation_table "$gensp" "$full_path" "$current_output_file"

# Process for 'entity' and 'entity_name' as a pair using the new function
process_entity_pairs "$gensp" "$full_path" "$current_output_file"


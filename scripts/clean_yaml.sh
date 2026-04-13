#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [-b] <yaml_file1> [yaml_file2 ...]"
    echo "Deletes blank YAML documents from one or more YAML files."
    echo ""
    echo "A blank YAML document is defined as:"
    echo "  1. Two consecutive YAML document separators (--- ---), possibly with blank lines in between."
    echo "  2. A single YAML document separator (---) at the very end of the file,"
    echo "     possibly followed by blank lines."
    echo ""
    echo "Options:"
    echo "  -b    Create a backup of the original file(s) with a '.bak' extension."
    echo "        By default, files are modified in-place without a backup."
    echo "  -h    Display this help message."
    echo ""
    echo "Examples:"
    echo "  $0 my_config.yaml"
    echo "  $0 -b file1.yaml file2.yaml"
    exit 1
}

# Default to no backup
CREATE_BACKUP=""

# Process command-line options
while getopts "bh" opt; do
    case ${opt} in
        b )
            CREATE_BACKUP=".bak"
            ;;
        h )
            usage
            ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done
# Shift positional parameters so that "$@" refers to the file arguments
shift $((OPTIND -1))

# Check if any files were provided after option parsing
if [ "$#" -eq 0 ]; then
    echo "Error: No YAML files provided." >&2
    usage
fi

# Check if perl is available on the system
if ! command -v perl &> /dev/null; then
    echo "Error: 'perl' command not found." >&2
    echo "Please install Perl to use this script. On most Linux systems, you can install it" >&2
    echo "using your package manager (e.g., 'sudo apt-get install perl' or 'sudo yum install perl')." >&2
    exit 1
fi

# Loop through each YAML file provided as an argument
for file in "$@"; do
    if [ ! -f "$file" ]; then
        echo "Warning: File '$file' not found. Skipping." >&2
        continue
    fi

    if [ ! -w "$file" ]; then
        echo "Warning: File '$file' is not writable. Skipping." >&2
        continue
    fi

    echo "Processing '$file'..."

    # Use Perl for robust multi-line regex replacements.
    # -0777: Slurp mode, reads the entire file content into memory as a single string.
    # -p:    Loops over input, prints the modified content.
    # -e:    Executes the Perl code provided as a string.
    # -i[SUFFIX]: Edits files in-place. If SUFFIX is provided (e.g., '.bak'),
    #             it creates a backup of the original file with that suffix.
    #             If SUFFIX is empty (like in our default case), no backup is created.
    #
    # Perl Code Explanation:
    # 1. `s/---\s*\n\s*---/\n---/sg;`
    #    - This regex handles the case of two consecutive `---` separators, including
    #      any blank lines or whitespace between them.
    #    - `---`: Matches the literal YAML document separator.
    #    - `\s*`: Matches zero or more whitespace characters (spaces, tabs, newlines).
    #             The `s` flag at the end makes `.` (and thus `\s`) match newlines.
    #    - `\n`: Matches a literal newline character, ensuring there's a line break
    #            between the two `---` separators.
    #    - The replacement `\n---` effectively consolidates two `---` into one,
    #      removing the empty document and any intermediate blank lines.
    #    - `s` flag: Allows `.` (and `\s`) to match newline characters. This is crucial
    #                for multi-line matching.
    #    - `g` flag: Performs a global replacement, matching all occurrences in the file.
    #
    # 2. `s/---\s*\z//s`
    #    - This regex handles the case of a `---` separator at the very end of the file,
    #      possibly followed by blank lines.
    #    - `---`: Matches the literal YAML document separator.
    #    - `\s*`: Matches zero or more trailing whitespace characters (including newlines).
    #    - `\z`: Matches the absolute end of the string (which is the end of the file
    #            content in slurp mode).
    #    - The replacement `//` (an empty string) deletes the matched `---` and any
    #      trailing blank lines.
    #    - `s` flag: (already active from the first regex, but noted for clarity).
    #
    # The order of these operations is important: first consolidate internal blank documents,
    # then remove any blank document at the very end of the file.
    perl -i"$CREATE_BACKUP" -0777 -pe 's/---\s*\n\s*---/\n---/sg; s/---\s*\z//s' "$file"

    if [ $? -eq 0 ]; then
        echo "Successfully processed '$file'."
    else
        echo "Error: Failed to process '$file'. Check file permissions or content." >&2
    fi
done

echo "Script finished."

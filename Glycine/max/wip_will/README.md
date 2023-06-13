# Using gmfi_finder.py

#### Purpose
The purpose of this script is to take in your .traits.yml file that is missing gene_model_full_ids and output an updated file with the correct gene_model_full_ids.

#### Requirements
1. This script requires the corresponding `.tsv` file for species you are looking at. i.e. `Glycine.pan3.YWTW.clust.tsv` for Glycine Max. This file can be found at https://data.legumeinfo.org/Glycine/GENUS/pangenes/Glycine.pan3.YWTW/. You will need to unzip this file using `gunzip Glycine.pan3.YWTW.clust.tsv.gz`. Additionally, you want this file to be in the same directory as the `gmfi_finder.py` script.
2. Then open up the file `gmfi_finder.py`in a text editor or IDE.
3. Look for the variable name `GLYMA_YAML_PATH` and `GLYMA_TSV_PATH`. You should make those varaibles the path to the `.yml` file and and `.tsv` file respectively.
4. Then locate where it says `gmfi_finder(GLYMA_TSV_PATH, GLYMA_YAML_PATH, 'g_outfile.yml')`. `g_outfile.yml` is the name of the output file, but you can change this to be whatever path you want.
5. Save and Run the script by running 

```bsh
 python gmfi_finder
```

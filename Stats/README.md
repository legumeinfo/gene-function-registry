# Gene Function Registry Statistics
This collection contains summary of statistics for the Gene Function Registry. These statistics are displayed in the registry.summary.txt file.  
## registry_summary.txt Report
This file contains registry totals for each species, and the registry as a whole for the following characteristics:

* Gene_Symbols
* Gene_models
* Citations
* Ontology Terms

The report displays two separate total lines.

The first line (registry-wide unique)is the total of Unique entries for that field in the registry as a whole.

The second line (SUM OF SPECIES) totals the numbers for all of the species included in the registry_summary.txt report.

Therefore, if a citation contains information for more than one species, it will be counted only one time in the "registry-wide unique" line, but two times in the "SUM OF SPECIES" line. 

Because the gene_symbols and gene_models are generally specific to a species, these two numbers should not differ for these categories.

## Generating registry_summary.txt Report
The report can be generated using the command

`python3 scripts/summarize_reports_wDate.py` 

on either the command line or within a codespace.

When this script is ran, it will overwrite the current report in the "Stats" folder.


# Gene Function and Phenotype

## Files
Experimentally-based information about gene function and plant phenotype, and the associated supporting references, are stored in three files per species, in a **gene_functions** directory.
Those files are the following - with "gensp" being the abbreviation for the present **gen**us and **sp**ecies:
- gensp.traits.yml
- gensp.citations.txt   (Note the "txt" extension; this file will be left uncompressed).
- gensp.references.txt  (Note the "txt" extension; this file will be left uncompressed).

A traits file corresponds with a publication, named with the pattern `Author_Author_YEAR.yml`, is produced by a curator, and represents minimal essential information about a gene and its function as described by literature cited in the file.

Periodically, the collection of yaml files in a Genus/species/studies directory will be combined and processed to produce a **gensp.traits.yml** file that will go into the datastore, for example into `Glycine/max/gene_functions/`. The processing for addition of gene function information to the datastore is, however, separate from the basic curation process.

<details>
<summary>More about generation of files for the datastore (advanced) ...</summary>

The **gensp.citations.txt** file is generated by the script **get_citations.pl** (in the [scripts directory](https://github.com/legumeinfo/gene-function-registry/tree/main/scripts) of the gene-function-registry repository), which takes gensp.traits.yml as input. This file has five fields: DOI, PubMedID, PubMedCentralID, Author-Author-Year, and full citation. (\*Note that the **get_citations.pl** script can help fill in reference elements in gensp.traits.yml -- specifically, adding doi given the pmid, or the pmid given the doi.)

The **gensp.references.txt** file is generated by the script **get_references.pl**, which takes the gensp.citations.txt as input. This file has the [MEDLINE-format](https://www.nlm.nih.gov/bsd/mms/medlineelements.html) publication information (authors, title, abstract, etc.) for the citations in gensp.citations.txt.

The traits.yml file contains one or more yaml "documents", indicated by three leading dashes (`---`) at the top of each document. Each holds information about one gene with experimentally-established function or trait association. A document might also be thought of as a "function card", with information about one gene for which a phenotypic effect has been established. 

</details>

## Curation and review process
Because the curation process for this type of data involves close reading and review of scientific literature, and because several curators will be doing this work, we will prepare the files away from the main Data Store. The workspace for drafting and reviewing the records is at the [gene-function-registry](https://github.com/legumeinfo/gene-function-registry), with the yaml documents going into the respective Genus/species/studies directories. In general, a yaml document is associated with a publication (aka "study"), and is named in the `Author_Author_YEAR.yml` pattern. A manuscript may describe one or several genes. Each gene "record" should have its own "document" within the yaml file, where a "document" is signified by a line with three dashes at the top of the document.

<strong>Note: After generating a new yaml file, check whether it is compliant yaml format with a format-checker such as <a href="https://www.yamllint.com">www.yamllint.com</a>.</strong>

After review and revision if needed, new gene records (as yaml documents) will be added to the appropriate gensp.traits.yml file in the Data Store. Draft curation work will go into the [gene-function-registry](https://github.com/legumeinfo/gene-function-registry) repository, and then go into the Data Store file system -- and from there, into the [datastore-metadata](https://github.com/legumeinfo/datastore-metadata) repository.

Protocols for the curation process will be maintained at the [datastore-specifications](https://github.com/legumeinfo/datastore-specifications) repository -- specifically, in [PROTOCOLS/gene_functions](https://github.com/legumeinfo/datastore-specifications/tree/main/PROTOCOLS/gene_functions). The other relevant working document is the [tracking spreadsheet](https://docs.google.com/spreadsheets/d/1hjBq1RSRtmjMVbzEEuKSQ1ArI8ydmVFBBkiA9ymWDrg/edit), where we'll note who is working on what manuscripts, and their status. 

## Content of the **gensp.traits.yml** file
There are ten top-level keys - four of which contain an array of key-value pairs. Note that if a value is not available for a (non-required) key, the key should simply be omitted (i.e. don't include the key without a value or with a blank or null in the value field).

```
---
scientific_name: Glycine max
classical_locus: E2
gene_symbols:
  - GmGI
gene_symbol_long: Earliness 2
gene_model_pub_name: Glyma.10G221500
gene_model_full_id: glyma.Wm82.gnm2.ann1.Glyma.10G221500
confidence: 5
curators:
  - Steven Cannon
comments: 
  - Mutational and association analysis relative to classical locus.
phenotype_synopsis: GmGI modulates flowering time, delaying expression of GmFT2a under long days.
traits:
  - entity_name: flowering time
    entity: TO:0002616
    relation_name: negatively regulates
    relation: RO:0002212
  - entity_name: days to maturity
    entity: TO:0000469
    relation_name: negatively regulates
    relation: RO:0002212
references:
  - citation: Tsubokura, Watanabe et al., 2013
    doi: 10.1093/aob/mct269
    pmid: 24284817
  - citation: Dietz, Chan et al., 2023
    doi: 10.3389/fpls.2022.889066
    pmid: 35574141
  - citation: Lin, Liu et al., 2021
    doi: 10.1111/jipb.13021
    pmid: 33090664
```

The **scientific_name** block is required. It holds the genus and species epithet, e.g. Glycine max

The **classical_locus** block is optional. It holds the name of a locus that has been defined in literature about this species, typically naming a mapped phenotype. For example, in soybean, the "E2" locus is one of several named "earliness" loci. In pea, the "I" locus was used by Mendel to name the yellow-or-green seed-color locus ("I" indicating  yellow and "i" indicating green). This block holds a single value.

The **gene_symbols** block is optional. It holds the name of a locus as described in literature about a mapped trait. This block may hold multiple values, since it is not uncommon for different publications to use different locus names. The first listed name will be considered "preferred."

The **gene_symbol_long** block is optional. It holds the "spelled out" or descriptive name of the gene symbol.

The **gene_model_pub_name** block is required. It holds the name of a gene as identified in the first citation from the "references" section. This gene name may be from any annotation. It will typically be "bare," without indication of assembly or annotation versions.

The **gene_model_full_id** block is required. It holds the fully-qualified gene ID, with components "gensp.Accession.gnm#.ann#.gene_ID". The "gene_ID" may be the same as **gene_model_pub_name**, but may be different if a corresponding and preferable gene model is available from another assembly and/or annotation. The purpose of this ID is to enable linking this gene to other resources at SoyBase/LIS/PeanutBase.

The **confidence** block is required. It is to have values [1-5]. This field indicates level of experimental support, with 5 being the strongest -- typically consisting of evidence at the level of a genetic complementation test, or otherwise observed as a mutant phenotype (experimental evidence code IMP) associated with the mutated form of the indicated gene. A level of 3 would be strong associational support, but lacking experimental lab validation such as genetic complementation. Levels 1 and 2 would be high-throughput evidence, and generally will NOT be collected in the SoyBase/LIS/PeanutBase projects. Papers that report lists of "candidate genes" in the vicinity of a GWAS or QTL region would be level 1 or 2 support, and should generally not be collected here.

The **comments** block is optional. It is for unstructured text, if needed for curatorial comments or other purposes. Comments must be entered as an array - i.e. with leading spaces and dash before each comment string.

The **phenotype_synopsis** block is required. It is for unstructured text, to give a brief human-readable description of the main phenotype associated with this gene (either through its wildtype or mutant form, but inferred relative to the mutant phenotype).

The **traits** block is required. It must contain at least one "entity" key with a valid ontology accession. Trait or Plant ontologies (TO and PO) are preferred where possible. Optionally (and generally discouraged due to the complexity and difficulty of getting this right), a modifying ontology term may be added to a trait block, in association with (listed underneath) an entity term. A modifier could be a "quality" or a "relation" key with a relation ontology may be associated with the entity ontology. Quality terms typically come from the Phenotype And Trait Ontology, [https://www.ebi.ac.uk/ols4/ontologies/pato](PATO) , and relation terms typically come from the Relations Ontology, [RP](https://www.ebi.ac.uk/ols4/ontologies/ro) The association between entity and relation ontology terms is established by proximity: entity and term followed by relation and term. However, to reiterate: focus on the primary entities, from TO or PO, and don't get bogged down with selecting modifiers.

The **references** block is required. It contains one or more blocks of citations, each containing three key-value pairs: "citation", "doi", and "pmid". Of these, the doi is required (some publications lack a pmid, but all should have a doi). The pmid should be provided if available (the **get_citations.pl** will do this if the curator does not). The citation should be in one of the following forms (depending on whether there are one, two, or three-or-more authors):  
```
  LastName, YEAR
  LastName, LastName, YEAR
  LastName, LastName et al., YEAR
```

## Updating gene_functions/ files: gensp.traits.yml, gensp.citations.txt, gensp.references.txt
The information in the gene function registry documents gets incorporated into a Mine instance for some species when the `gensp.traits.yml` file
is generated and copied to the `gene_functions` section of the public data store. This is a step that some curator has to initiate.
These files are generated with two scripts, like so (assuming the scripts have been added to the user's PATH):
```
  salloc --account=legume_project
  ml miniconda
  source activate ds-curate

  get_citations.pl -cit_out Glycine/max/gene_functions/glyma.citations.txt \
                   -yml_out Glycine/max/gene_functions/glyma.traits.yml \
                   -verbose -over \
                   Glycine/max/studies/*yml

  get_references.pl -out Glycine/max/gene_functions/glyma.references.txt \
                    Glycine/max/gene_functions/glyma.citations.txt
```

<details>
<summary>MORE: To run these scripts for all species, call them in a loop, driven by a file with the genus, species, and gensp names:</summary>

```
cat templates/genus_species.tsv
  Glycine max glyma
  Glycine soja glyso
  Lotus japonicus lotja
  Medicago truncatula medtr
  Phaseolus vulgaris phavu
  Pisum sativum pissa
  Vicia faba vicfa
  Vigna radiata vigra


cat templates/genus_species.tsv | while read -r line; do
  genus=`echo $line | awk '{print $1}'`
  species=`echo $line | awk '{print $2}'`
  gensp=`echo $line | awk '{print $3}'`
  echo "$genus $species $gensp"

  get_citations.pl -cit_out $genus/$species/gene_functions/$gensp.citations.txt \
                   -yml_out $genus/$species/gene_functions/$gensp.traits.yml \
                   -verbose -over \
                      $genus/$species/studies/*yml

  get_references.pl -out $genus/$species/gene_functions/$gensp.references.txt $genus/$species/gene_functions/$gensp.citations.txt

done
```
</details>

Once the files have been updated in each `$genus/$species/gene_functions`, then copy those files over to the main datastore, 
and also update the `datastore_metadata` GitHub repository.

<details>
<summary>MORE: To copy files for each species to the datastore, again call them in a loop:</summary>

```
cat templates/genus_species.tsv | while read -r line; do
  genus=`echo $line | awk '{print $1}'`
  species=`echo $line | awk '{print $2}'`
  gensp=`echo $line | awk '{print $3}'`
  echo "$genus $species $gensp"

  cp $genus/$species/gene_functions/*.* /project/legume_project/datastore/v2/$genus/$species/gene_functions/
done
```
</details>


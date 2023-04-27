# Experimental Gene Function

Experimentally-based information about gene function is stored in a single file per species, in a "gene_functions" directory.

Filename: gensp.function.yml

The file is in yaml format, and contains one or more sections or "documents" (in yaml terminology), each holding information about one gene with experimentally-established function or trait association. A "document" might be called a "record" in database terminology. It might also be thought of as a "function card", with information about one gene for which a phenotypic effect has been established. 

Each such gene-function document (/section/record/card) is indicated by three dashes (`---`) at the top of the document.

There are seven top-level keys - two of which contain an array of key-value pairs:

```
---
classical_locus: E2
gene_symbols:
  - GmGI
gene_symbol_long: Gigantea
pub_gene_model: Glyma.10G221500
datastore_gene_id: glyma.Wm82.gnm2.ann1.Glyma.10G221500
confidence: 5
traits:
  - entity: TO:0002616    # flowering time trait
  - relation: RO:0002212  # negatively regulates
  - entity: TO:0000469    # days to maturity
  - relation: RO:0002212  # negatively regulates
references:
  - citation: Tsubokura, Watanabe et al., 2013
  - doi: 10.1093/aob/mct269
  - pmid: 24284817
  - citation: Dietz, Chan et al., 2023
  - doi: 10.3389/fpls.2022.889066
  - pmid: 35574141
  - citation: Lin, Liu et al., 2021
  - doi: 10.1111/jipb.13021
  - pmid: 33090664
```

The "classical_locus" block is optional. It holds the name of a locus that has been defined in literature about this species, typically naming a mapped phenotype. For example, in soybean, the "E2" locus is one of several named "earliness" loci. In pea, the "I" locus was used by Mendel to name the yellow-or-green seed-color locus ("I" indicating  yellow and "i" indicating green). This block holds a single value.

The "gene_symbols" block is optional. It holds the name of a locus as described in literature about a mapped trait. This block may hold multiple values, since it is not uncommon for different publications to use different locus names. The first listed name will be considered "preferred."

The "gene_symbol_long" block is optional. It holds the "spelled out" or descriptive name of the gene symbol.

The "pub_gene_model" block is required. It holds the name of a gene as identified in the first citation from the "references" section. This gene name may be from any annotation. It will typically be "bare," without indication of assembly or annotation versions.

The "datastore_gene_id" block is required. It holds the fully-qualified gene ID, with components "gensp.Accession.gnm#.ann#.gene_ID". The "gene_ID" may be the same as "pub_gene_model", but may be different if a corresponding and preferable gene model is available from another assembly and/or annotation. The purpose of this ID is to enable linking this gene to other resources at SoyBase/LIS/PeanutBase.

The "traits" block must contain at least one "entity" key with a valid ontology accession. Trait ontology is preferred where possible. Optionally, a "relation" key with a relation ontology may be associated with the entity ontology. The association between entity and relation ontology terms is established by proximity: entity and term followed by relation and term. Optionally (for the benefit of curators), a comment (marked by "#") may be added to the ontology-term lines.

The "references" block contains one or more blocks of citations, each containing three key-value pairs: "citation", "doi", and "pmid". Of these, either the pmid or doi is required (some publications lack a pmid, but all should have a doi). The citation should be in one of the following forms (depending on whether there are one, two, or three-or-more authors):  
```
  LastName, YEAR
  LastName, LastName, YEAR
  LastName, LastName et al., YEAR
```


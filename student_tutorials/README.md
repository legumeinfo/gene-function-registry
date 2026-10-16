## Tutorials

### How to read and analyze a research paper

[Ten simple rules for reading a scientific paper](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1008032)

[Art of reading a journal article](https://journals.lww.com/jpat/fulltext/2013/17010/art_of_reading_a_journal_article__methodically_and.14.aspx)

### Practice Material
- Within the [practice](./practice) folder is a [reference to a scientific paper](https://academic.oup.com/jxb/article/68/3/469/2645555) and an example curatation document. 

### General curation information
<details>

- We use a "Genus species" code for curation. We use the first three letters of the <b>gen</b>us and the first two letters of the <b>sp</b>ecies (Example: <i>Glycine max</i> == glyma)

- Advanced gene function curation protocol can be found [here](https://github.com/legumeinfo/datastore-specifications/blob/main/PROTOCOLS/gene_functions/README.md)

</details>

### Selecting and accessing research papers
<details>
    
1. The publications can be selected from the "Gene_Function_Registry" collection in Zoterro that Jacqueline will invite you to.
   - The curator should right click on the paper and select "Add Note".  The first line of the Note will become the title of the note in the collection.  Title the note WIP_Curator Name so other curators know that this paper is already currently being analyzed.  When you finish the yml file, change the first line to "Done_Curator Name_Date".  Jacqueline will periodically go through and remove finished publications from the collection.<br><br>
    
2. The publications in the collection should all have the full PDF attached so you can read the paper in Zoterro.  If you choose to, you can take notes about the paper in your WIP note. Alternatively, you may choose to just have the paper open in one window and your yml curation file open in a second window and enter information directly into it.<br><br>
    
3. Once you have chosen a paper, it is a good idea to double check that the paper has not already been added to the registry.  (If everyone follows step 1 above, it shouldn't, but it happens).  The yml file (and any branches created prior to being merged to main) will be named "Gensp.First Author Last Name_Second Author Last Name_Year".  Look at the existing branches, as well as the "Studies" folder under the specific species referred to in your paper to ensure that there is no identical entries.<br><br>
    
4. **RUN REPORTS - TO DO** <br><br>

5. There is a sub-folder within this collection called "For Future Assessment." These are papers that a curator decided did not have strong enough evidence to warrant a yml entry on their own, but they can be supported to additional papers later.  The gene symbols and species for these papers should be included as tags.  It's a good idea to filter the tags in Zoterro by the gene symbo(s) used in your paper to check that these papers do not provide additional support or information regarding your specific gene symbol.
</details>

### How to curate with GitHub
<details>
    
1. Make a branch from 'main' and name it "gensp.Author_Author_Year" (example: glyma.Song_Montes-Luz_2022)<br><br>
    
2. Create a new issue using "gensp.Author_Author_Year" so that students and mentors (other curators) can easily discuss issues with curating the research paper <b><i>NOTE: are we still doing this process - it seems like now we are not making an Issue unless there is a problem (e.g. broken link) or question about something?</b></i><br><br>
    - The issue can be closed once the curation for the particular paper is done (done == reviewed and merged).
    
3. Copy the [curation template](https://github.com/legumeinfo/gene-function-registry/blob/main/templates/gensp.traits.yml) and rename the file "gensp.Author_Author_Year.yml" (example: glyma.Song_Montes-Luz_2022.yml)<br>
   - Make sure to use the date the paper was published in the journal not the date the paper was first published online (generally this should be the date in the paper's citation).<br><br>

4. Once you've completed the gensp.traits.yml document, use the YAML Lint website to check for formatting errors.
   - Highlight and copy the entire .yml file and paste it into the entry box at [YAML Lint](https://www.yamllint.com/) at https://www.yamllint.com/.
   - Click `GO` in the lower right hand corner.
   - YAML Lint will read the file, shorten the lines to 80 characters each (for readability), and tell you if there are any formatting errors.  If the bar below the box turns green and says either "Valid YAML!" or "Multiple documents detected. Valid YAML!" there are no formatting errors.
   - YAML sees the line `---` as the beginning of a new "document."  In the gene function registry, each separate gene symbol within a publication is treating as a new "entry" or "document".  So a single YAML file may have multiple "documents" if a publication addressed multiple gene symbols.  If you intended your file to only address a single gene symbol but you get the message "Multiple documents detected..." double check that there is not a second copy of the `---` line in your file.
   
</details>

### Branch management using Git on the terminal
<details>

- To start a brand new branch on your own computer first start within the correct directory.  Within the terminal use the command `git checkout -b gensp.Author_Author_YEAR` or ```git branch (new_branch_name)``` followed by ```git switch (new_branch_name)```.

- To create a new branch on your local device that tracks a branch already present at https://github.com/legumeinfo/gene-function-registry, use the command `git checkout --track origin/(remote_branch_name)` in the terminal.

- If the local branch has no upstream branch at GitHub created earlier, you cannot simply push your file changes.  Rather, to push the current branch and set the remote as upstream, use one of the following commands; `git push --set-upstream origin (local_branch_name)` or `git push -u origin (local-branch_name)`.

- To rename a local branch first change directories to within that branch and use the command `git branch -m (new_branch_name)`.  Additionally, you may rename a branch from within any other local branches using `git branch -m (old_branch_name) (new_branch_name)`.

- To rename a remote branch that exists at GitHub, you must first delete the older one with the command `git push origin --delete (old_remote_branch_name)`.  You then push the newly renamed local branch using `git push origin -u (new_local_branch_name)`.

- Save and track versions of your files using git and GitHub.  You should save your local files to a hard drive regularly during the workday, create saved local versions at least daily using git, and push your local versions (commits) to the shared workspace on https://github.com/legumeinfo/gene-function-registry.

- The `git status` command will help you find recent updates to your local branch and how they contrast with the remote repository.  Git status compares the contents of the local `.git` to the contents of GitHub, and you can decide to reconcile them using `git push`, `git fetch`, `git pull`, etc.

- The commands `git fetch` followed by `git pull` take the latest updates at the remote website GitHub and place them into the repository of `.git` on your local device.  Hence your local version of the branch, e.g. "main" is made identical to the tracked branch on GitHub.

- The command `git add` tells git locally about new or altered files and updates these versions to `.git`.  For example on the command line: `git add path/file1 path/file2 path/file3`.  To remove files from your local latest version use the command `git rm`.  The `git add` and `git rm` stage files so they are ready for a `git commit`.  You can use `git status` to see if there are files that have been changed and hence need addition or removal.

- We create a new recorded version of our directories using the command `git commit -m`.  The `git commit` ensconces new or changed files made available by `git add` and `git rm` within `.git`.  The `-m` option allows you to write a brief message describing the new updates for your records.

- The record of "commits" and other changes within your git repository may be seen using `git log`.  The command `git branch` allows you to see all the possible branches available in the directory and `git branch -a` shows the tracking branches at GitHub.  Shift from one branch to another using `git switch (different_branch_name)`.

- The `git push` command then takes the updates in local `.git`, which have been staged ready for the push by `git-commit`, and pushes (uploads) the staged files to a remote repository at github.com.  Requires a sign-in or permission to access and use `git-push` in the command line without specifying the files.

</details>

### The components of the YAML file
This section will discuss the individual components of the YAML file with information on what should be included, and how to find the information. 

Each section will start by stating whether a particular component is required to be included in the YAML file or not.  If a component is not required, and you are not including it - you can delete the line containing that component.

#### Scientific_name: REQUIRED
<details>
    The two-word binomial, e.g. Glycine max
</details>

#### Classical Locus: Not Required
<details>
    Name of the locus (if available) from classical genetic studies. An example of this may be the R locus characterized by Mendel for seed shape in the pea plant (Round vs Wrinkled). This may not be mentioned in more recent papers that are not studying traits characterized by classical breeding studies.
</details>

#### Gene Symbols: REQUIRED
<details>
    This field is required to be listed as an array (or list), even if there is just a single gene symbol being listed. The gene symbol should be the abbreviated gene name as listed in the paper. For Example, "GmNNC1".  Note that the gene symbol must start with a 2 letter designation from the scientific name of the species with the first letter capitalized for the Genus name and the second letter lower case for the species name.<br><br>

If there are multiple names for one gene, enter them on separate lines with the most common name entered first.<br><br>

If more than one gene is described in the same paper, paste another copy of the YAML template below the first one (starting with the line "---" and describe all sections of the YAML file for the separate gene.
</details>

#### Gene Symbol long: REQUIRED
<details> 
    The long-hand version of the gene-symbol acronym, e.g. "Nodule Number Control 1".  You do not need to include the prefix for the scientific name (i.e. "Gm" for Glycine max).
    
Most of the time this is going to be listed in the publication. In the event it is not listed, the easiest place to find this would be on the [NCBI Gene search](https://www.ncbi.nlm.nih.gov/gene/) website.

If for some reason the gene symbol does not come up in the NCBI website (this is rare, but it happens), search the term on Google to see if a gene name or protein name (that makes sense with the topic of the publication) comes up. For example, the gene symbol given in this guide "GmNNC1" does not actually return results in the NCBI gene website, but Google will return the correct Gene_symbol_long.
</details>

#### Gene model pub name: REQUIRED
<details> 
    Ideally, this will be the gene model as it is listed in the publication, e.g. Glyma02g17170.2, SoyW82_02G12800.1 or Glyma.02G152800 depending on the annotation version.<br><br>

Occasionally, the publication will list the gene model as something different. such as a Genbank accession number (XP_004493127) or an author-given gene name.  While these aren't ideal, the Gene_model_pub_name should be something that is directly linked to that publication. If you have to use an author given name, or another unconventional publication name, state how the name was obtained as a comment in the comments section below.
</details>

#### Gene model full id: REQUIRED
<details> 
    This field is often the one that takes the most work to find.  The gene_model_full_id must directly link to a gene model in the LIS (Legume Information System).  Often, this specific identifier is not listed in the paper, or even in the supplementary data. Below, are several different examples of steps to finding the gene_model_full_id ranging from most simplistic to a little more work.<br><br>

**Case 1: Your gene model pub name is in the preferred format listed above (e.g. Glyma02g17170.2)**
This is the easiest case to find the gene_model_full_id.  Go to the ["Gene Identifier Search"](https://www.legumeinfo.org/tools/search/gene.html) at [Legume Information System Website](https://www.legumeinfo.org/) at https://www.legumeinfo.org/tools/search/gene.html and enter the gene_model_pub_name into the "Identifier" field and select the Genus you are looking at. Note, if your pub name has a .1 or .2 at the end of it, this is a splice variant and you should remove that portion of the name before performing the search.  See the screenshot below as an example of searching for the pub_name example "Glyma02g17170.2" from the previous section, and example results.

<img width="1477" height="1138" alt="image" src="https://github.com/user-attachments/assets/5471c462-ba70-4c3c-94e9-d35f48ff9975" />

Your gene_model_full_id is the gene model listed in the 2nd column of the results under "Identifier" (see red box in the image above).  The identifier has a specific format with 5 fields separated by periods.  It begins with the 5 letter abbreviation for genus species (glyma for Glycine max), then the cultivar name (in this case "Wm82" for "Williams82", then the genome assembly (in this case "gnm1" referring to assembly 1), then the annotaation (in this case "ann1" for annotation 1, and finally the gene name ("Glyma02g17170"). In this case, there was a single result.  If the search returns more than one result, you want to generally use the highest annotation number listed, as this is usually the newest annotation.

**Case 2: Your pub_name returns no results in the search or is in a different format**
If your pub_name returns no search results or is in a different format, your first step is to search that pub_name in the NCBI database (discussed above in the "Gene Symbol Long" Section. If this returns a result, go to the "Transcripts and Proteins table"  (See red arrow in screenshot example below for the pub name "EU391460.1").
<img width="1442" height="978" alt="image" src="https://github.com/user-attachments/assets/f02538fd-5847-463d-8289-568618f88958" />

Once on that page, you can select either the transcript (mRNA) accession ("NM_####" or "XM_#####") or the protein accession ("NP_####" or "XP_#####"). You may get the same results with either in the following steps, but the protein sequence is more likely to be conserved.  For well studied species such as Glycine max (soybean) either should work.  If the paper is looking at a species with less resources, the protein sequence might be the best choice to try first.  The example below uses the mRNA sequence.
<img width="1478" height="797" alt="image" src="https://github.com/user-attachments/assets/cd069831-50ab-4c46-acd4-f639617cb3f7" />

Clicking on either of these will take you to the mRNA or protein accession page of the gene.  Click on the "FASTA" just below the gene name to get to the specific mRNA or protein sequence.
<img width="1457" height="791" alt="image" src="https://github.com/user-attachments/assets/9c107a42-593a-4d10-b09c-bd8bd8ec95f5" />

(You can actually get to these sequences further down in the page, but this is just a bit of a cleaner way to get it.) Highlight and copy the resulting sequence.
<img width="1469" height="1201" alt="image" src="https://github.com/user-attachments/assets/8d2d1fc8-4402-45ff-a3bd-fdefe80ff714" />

You will now go back to the [Legume Information System](https://www.legumeinfo.org/) main page and select ["Sequence Search (Blast)"](https://sequenceserver.legumeinfo.org/).  Here, you will paste the copied sequence into the search box and then select the specific scientific name for the apecies your paper is referring to.  Generally you will be using either an mRNA sequence or a protein sequence.  For mRNA sequences, you'll use the "mRNA_Sequence_Collection" in the lower half of the first column.  In the example below, the "Genomic_Sequence_Collection" has been collapsed so that the sequence box and the list of species fit on the screen. In this example I have pasted the first line with the description of the FASTA sequence starting with the ">" and the sequence.  The search tool does require a FASTA format using a first line that starts with ">".  What is typed after doesn't matter - it's just seen as a descriptor.
<img width="1472" height="1391" alt="Screenshot 2026-10-14 144730" src="https://github.com/user-attachments/assets/be85ea61-efda-41bc-8da4-d944e0e22f8f" />

The results page will show the top set of results.  Typically the gene model you are looking for should be one of the first ones. As in the example below, you may hit to some sequences of closely related species.  Your gene_model_full_id should be from the same species as you listed in the scientific name. <br><br>
As you can see in the example below, the first result had 96% Query Coverage and 100% identity.  This is the type of result you are looking for, although sometimes it won't be quite as high, especially in less studied species.  If you don't see a strong result using mRNA, try using the protein sequence in the steps above.<br><br>

Clicking on the top result just moves you down the page to the details for that result. The full identifier is the gene_model_full_id. You can copy the gene_model_full_id from either spot.
<img width="1480" height="1381" alt="Screenshot 2026-10-14 151615" src="https://github.com/user-attachments/assets/e5d4997b-4275-4329-8031-495058587fa5" />
</details>

#### Confidence Value: REQUIRED
<details>
    This is a value from 1 to 5 showing how strong the evidence for the gene's function is.<br><br>

**How to determine it:**<br><br>
_Short Answer:_ This field indicates the level of experimental support for the candidate gene, with 5 being the strongest and 1 the weakest.  Search your feelings and write down a plausible number as this task doesn't merit substantial investment.<br><br>

_Long Answer:_ Level **5**, and to a lesser extent  **4**, typically consist of strong experimental evidence such as genetic complementation tests or observations of mutant phenotypes associated with alleles of the gene-of-interest. <br><br>
A level of **3** would represent strong associational support, but lacking experimental laboratory validation to demonstate causation over correlation. For example, if specific transformation experiments and observations of mutant alleles were not observed in the specified species, but a related species or close outgroup (such as Arabidopsis) would warrant a level 3 (or possibly a low level **4** if it has been observed in multiple species). <br><br>

In general, publications being entered into the gene function registry should be at a level **3** or higher.<br>
Levels **1** and **2** would be largely high-throughput evidence and weak associations that generally should not be collected or prioritized.  For example, papers that report lists of "candidate genes" due to being in the vicinity of a GWAS or QTL region would be level **1** or **2** support.
</details>

#### Curators: REQUIRED
This section lists who created the yaml file. Put your name here. This section is required to be an array (a list) so you must have the following format for the validator to read it correctly.<br>
Curators:<br>
    - _Your name here_
    
#### Comments: REQUIRED
<details> 
    This section should consist of 5 to 7 comments describing the gene's function (to the extent it is known), other genes it interacts with, and a brief summary of the publication findings that led you to the confidence value you gave it.<br>

_Example describing the gene:_ "- A cytochrome P450 superfamily protein"<br>
_Example validating confidence value_" - Gene function established using mutation, expression, and related function tests."<br><br>
If the gene affects/is affected by another gene you have curated, include the name of the yml file which discusses the interacting gene.<br>
_Example of an interaction:_ "miR172c cleaves the protein product of the NNC1, allowing ENOD40 to be transcribed. miR172c is negatively regulated by NARK (see Searle_Men_2003.yml)."

This is also the section to include where you found the gene_model_pub_name if it is not obvious, and how you determined the gene_model_full_id if you needed to use the LIS resources to search for the full id.<br>
_Example:_ "- Gene_model_full_id was identified by searching the FASTA format protein
    sequence from the Genbank Accession against the Cicer arietinum CDCFrontier
    v3.1 proteins database on Cicer Resources Portal
    (https://cicer.legumeinfo.org/)."
</details>

#### Phenotypic Synopsis: REQUIRED
<details> 
    This should be 1 to 2 sentences describing the phenotype, e.g. "NNC1 is a transcription factor that negatively regulates nodule number by repressing GmENOD40."<br><br>

Note that while the comments section is required to be a list (each statement starts with an indented "-"), this section is not so the statement should be placed directly after the ":".  "Phenoytypic_synopsis:" _Your comment here_
</details>

#### "Traits" Ontology Section: REQUIRED (at least 1)
<details>
    Immediately after the Phenotypic_synopsis section is a section to include Ontology terms for the gene function. Each term consists of a two-line entry.  Line 1 is the _entity name_ and Line 2 is the _entity__ (or term ID). These terms can be searched for using the process below.  You are required to have at least 1 entity, but sometimes may have several.<br>

_Example:_ <br>
traits:<br>
    entity_name: _the name of the ontology accession,_ e.g. "nodulation"<br>
    - entity: _The ontology accession code,_ e.g. TO:#####<br>

**To find ontology terms:**
- Head to the [Ontology Lookup Service](https://www.ebi.ac.uk/ols4) website at "https://www.ebi.ac.uk/ols4" and search in the field under "Welcome to the EMBL-EBI Ontology Lookup Service".  Use keywords and likely trait names to search for ontology terms within their records and travel along the branches of the ontology trees to compare and contrast options.

- Ontologies considered of high value to our project are the Trait Ontology (TO) "describes phenotypic traits in plants. Each trait is a distinguishable feature, characteristic, quality or phenotypic feature of a developing or mature plant", Gene Ontology (GO) "describing the functions of gene products from all organisms", and Plant Ontology (PO) "describes plant anatomy, morphology, and growth and development in plants".

- There are ontologies specific to certain organisms that may also be included such as the [Soybean Trait Ontology (SOY)](https://amigo.soybase.org/amigo/amigo/term/SOY:0000099) at "https://amigo.soybase.org/amigo/amigo/term/SOY:0000099" and the variety of [Crop Ontologies (CO)](https://cropontology.org) at "https://cropontology.org".

- Typically we will list Trait Ontologies (TO) first, then  Gene Ontologies (GO), and then any other ontology terms we use.
</details>

#### References: REQUIRED
<details>
    At least 1 reference is required for each gene (typically the publication you are reporting on).  If possible include both the pmid (Pubmed ID) and the doi, however at least 1 of these needs to be included for each citation.

- If you used other references in searching for the gene function (other publications, not websites) include those in this section as well.  For example, if an Orthologous gene in another species is used to validate the confidence level, include that reference.
- This section may also contain papers that are added later when more information about the gene function is published.
</details>

## Tutorials

### How to read and analyze a research paper

[Ten simple rules for reading a scientific paper](/student_tutorials/Carery_Steiner_2020.pdf)

[Art of reading a journal article](/student_tutorials/Subramanyam_2013.pdf)

### Practice Material
- Within the [practice](https://github.com/legumeinfo/gene-function-registry/tree/main/student_tutorials/practice) folder is a reserach paper and curatation document. 

### General curation information
<details>
- We use a "Genus species" code for curation. We use the first three letters of the <b>gen</b>us and the first two letters of the <b>sp</b>ecies (Example: <i>Glycine max</i> == glyma)
- Advanced gene function curation protocol can be found [here](https://github.com/legumeinfo/datastore-specifications/tree/main/PROTOCOLS/gene_functions)
</details>

### Selecting and accessing research papers
1. The manuscript should be selected from the Google Docs <a href="https://docs.google.com/spreadsheets/d/1hjBq1RSRtmjMVbzEEuKSQ1ArI8ydmVFBBkiA9ymWDrg/edit?usp=sharing" target="_blank">tracking sheet</a>, and then note in the spreadsheet the status
    - Curator will note "WIP_Name" in the column called "doc status" (example: WIP_Steven)
2. Using the Title, Author and Year or DOI a curator can find the research paper using any of these sites:
    - [Google Scholar](https://scholar.google.com/)
    - [PubMed](https://pubmed.ncbi.nlm.nih.gov/)
    - [PubAg / USDA National Ag Library](https://search.nal.usda.gov/discovery/search?vid=01NAL_INST:MAIN&search_scope=pubag&tab=pubag)



### Branch management using the Graphical User Interface (GUI) on GitHub
<details>
1. Make a branch from 'main' and name it "gensp.Author_Author_Year" (example: glyma.Song_Montes-Luz_2022)
2. Create a new issue using "gensp.Author_Author_Year" so that students and mentors (other curators) can easily discuss issues with curating the research paper
    - The issue can be closed once the curation for the particular paper is done (done == reviewed and merged).
3. Copy the [curation template](https://github.com/legumeinfo/gene-function-registry/blob/main/templates/gensp.traits.yml) and remain the file "gensp.Author_Author_Year.yml" (example: glyma.Song_Montes-Luz_2022.yml)
</details>

### Branch management using Git on the terminal
<details>
- To start a brand new branch on your own computer first start within the correct directory.  Within the terminal use the command "git checkout -b gensp.Author_Author_YEAR" or "git branch (new_branch_name)" followed by "git switch (new_branch_name)".

- To create a new branch on your local device that tracks a branch already present at https://github.com/legumeinfo/gene-function-registry, use the command "git checkout --track origin/(remote_branch_name)" in the terminal.

- If the local branch has no upstream branch at GitHub created earlier, you cannot simply push your file changes.  Rather, to push the current branch and set the remote as upstream, use one of the following commands; "git push --set-upstream origin (local_branch_name)" or "git push -u origin (local-branch_name)".

- To rename a local branch first change directories to within that branch and use the command "git branch -m (new_branch_name)".  Additionally, you may rename a branch from within any other local branches using "git branch -m (old_branch_name) (new_branch_name)".

- To rename a remote branch that exists at GitHub, you must first delete the older one with the command "git push origin --delete (old_remote_branch_name)".  You then push the newly renamed local branch using "git push origin -u (new_local_branch_name)".

- Save and track versions of your files using git and GitHub.  You should save your local files to a hard drive regularly during the workday, create saved local versions at least daily using git, and push your local versions (commits) to the shared workspace on https://github.com/legumeinfo/gene-function-registry.

- The “git status” command will help you find recent updates to your local branch and how they contrast with the remote repository.  Git status compares the contents of the local “.git” to the contents of GitHub, and you can decide to reconcile them using git push, git fetch, git pull, etc.

- The commands “git fetch” followed by “git pull” take the latest updates at the remote website GitHub and place them into the repository of “.git” on your local device.  Hence your local version of the branch, e.g. "main" is made identical to the tracked branch on GitHub.

- The command “git add” tells git locally about new or altered files and updates these versions to “.git”.  For example on the command line: git add path/file1 path/file2 path/file3.  To remove files from your local latest version use the command "git rm".  The "git add" and "git rm" stage files so they are ready for a "git commit".  You can use "git status" to see if there are files that have been changed and hence need addition or removal.

- We create a new recorded version of our directories using the command “git commit -m”.  The “git commit” ensconces new or changed files made available by “git add” and "git rm" within “.git”.  The “m” option allows you to write a brief message describing the new updates for your records.

- The record of "commits" and other changes within your git repository may be seen using "git log".  The command "git branch" allows you to see all the possible branches available in the directory and "git branch -a" shows the tracking branches at GitHub.  Shift from one branch to another using "git switch (different_branch_name)"

- The “git push” command then takes the updates in local “.git”, which have been staged ready for the push by “git-commit”, and pushes (uploads) the staged files to a remote repository at github.com.  Requires a sign-in or permission to access and use “git-push” in the command line without specifying the files.
</details>



### How to find ontology terms
- Head to the website "https://www.ebi.ac.uk/ols4" and search in the field under "Welcome to the EMBL-EBI Ontology Lookup Service".  Use keywords and likley trait names to search for ontology terms within their records and travel along the branches of the ontology trees to compare and contrast options.

- Ontologies considered of high value to our project are the Trait Ontology (TO) "describes phenotypic traits in plants. Each trait is a distinguishable feature, characteristic, quality or phenotypic feature of a developing or mature plant", Gene Ontology (GO) "describing the functions of gene products from all organisms", and Plant Ontology (PO) "describes plant anatomy, morphology, and growth and development in plants".

- There are ontologies specific to certain organisms that may also be included such as the Soybean Trait Ontology (SOY) "https://amigo.soybase.org/amigo/amigo/term/SOY:0000099" and the variety of Crop Ontologies (CO) "https://cropontology.org".


#### How do determine the 'Confindence Value'
<details>
- Short Answer: The confidence block is to have values 1 through 5.  This field indicates level of experimental support for the candidate gene, with 5 being the strongest and 1 the weakest.  Search your feelings and write down a plausible number as this task doesn't merit substantial investment.
- Long Answer: The S-Tier level of 5, and to a lesser extent 4, typically consist of strong experimental evidence such as genetic complementation tests or observations of mutant phenotypes associated with alleles of the gene-of-interest.  A level of 3 would represent strong associational support, but lacking experimental laboratory validation to demonstate causation over correlation.  Levels 1 and 2 would be largely high-throughput evidence and weak associations that generally should not be collected or prioritized.  For example, papers that report lists of "candidate genes" due to being in the vicinity of a GWAS or QTL region would be level 1 or 2 support.
</details>

#### FAQ about Git, GitHub and curation
- 

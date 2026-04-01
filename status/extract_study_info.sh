#!/usr/bin/env bash

# Output file
GLYMA="glyma_$(date +%Y-%m-%d).txt"
GLYSO="glyso_$(date +%Y-%m-%d).txt"
ARAHY="arahy_$(date +%Y-%m-%d).txt"
LOTJA="lotja_$(date +%Y-%m-%d).txt"
MEDSA="medsa_$(date +%Y-%m-%d).txt"
MEDTR="medtr_$(date +%Y-%m-%d).txt"
PHAVU="phavu_$(date +%Y-%m-%d).txt"
PISSA="pissa_$(date +%Y-%m-%d).txt"
VICFA="vicfa_$(date +%Y-%m-%d).txt"
VIGRA="vigra_$(date +%Y-%m-%d).txt"


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$GLYMA"

cat ../Glycine/max/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$GLYMA"


echo "
---------------------ENTITY NAME--------------------------
" >> "$GLYMA"

cat ../Glycine/max/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$GLYMA"

echo "
---------------------ENTITY--------------------------
" >> "$GLYMA"

cat ../Glycine/max/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$GLYMA"

echo "
---------------------DOI--------------------------
" >> "$GLYMA"

cat ../Glycine/max/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$GLYMA"

echo "
---------------------PMID--------------------------
" >> "$GLYMA" 

cat ../Glycine/max/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$GLYMA"


############################################
############# Glycine soja  ################
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$GLYSO"

cat ../Glycine/soja/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$GLYSO"


echo "
---------------------ENTITY NAME--------------------------
" >> "$GLYSO"

cat ../Glycine/soja/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$GLYSO"

echo "
---------------------ENTITY--------------------------
" >> "$GLYSO"

cat ../Glycine/soja/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$GLYSO"

echo "
---------------------DOI--------------------------
" >> "$GLYSO"

cat ../Glycine/soja/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$GLYSO"

echo "
---------------------PMID--------------------------
" >> "$GLYSO" 

cat ../Glycine/soja/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$GLYSO"


############################################
############# Arachis hypogaea #############
############################################

echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$ARAHY"

cat ../Arachis/hypogaea/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$ARAHY"


echo "
---------------------ENTITY NAME--------------------------
" >> "$ARAHY"

cat ../Arachis/hypogaea/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$ARAHY"

echo "
---------------------ENTITY--------------------------
" >> "$ARAHY"

cat ../Arachis/hypogaea/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$ARAHY"

echo "
---------------------DOI--------------------------
" >> "$ARAHY"

cat ../Arachis/hypogaea/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$ARAHY"

echo "
---------------------PMID--------------------------
" >> "$ARAHY" 

cat ../Arachis/hypogaea/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$ARAHY"

############################################
############# Lotus japonicus  #############
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$LOTJA"

cat ../Lotus/japonicus/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$LOTJA"


echo "
---------------------ENTITY NAME--------------------------
" >> "$LOTJA"

cat ../Lotus/japonicus/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$LOTJA"

echo "
---------------------ENTITY--------------------------
" >> "$LOTJA"

cat ../Lotus/japonicus/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$LOTJA"

echo "
---------------------DOI--------------------------
" >> "$LOTJA"

cat ../Lotus/japonicus/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$LOTJA"

echo "
---------------------PMID--------------------------
" >> "$LOTJA" 

cat ../Lotus/japonicus/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$LOTJA"

############################################
############# Medicago sativa  #############
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$MEDSA"

cat ../Medicago/sativa/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$MEDSA"


echo "
---------------------ENTITY NAME--------------------------
" >> "$MEDSA"

cat ../Medicago/sativa/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$MEDSA"

echo "
---------------------ENTITY--------------------------
" >> "$MEDSA"

cat ../Medicago/sativa/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$MEDSA"

echo "
---------------------DOI--------------------------
" >> "$MEDSA"

cat ../Medicago/sativa/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$MEDSA"

echo "
---------------------PMID--------------------------
" >> "$MEDSA" 

cat ../Medicago/sativa/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$MEDSA"

############################################
########## Medicago truncatula  ############
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$MEDTR"

cat ../Medicago/truncatula/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$MEDTR"


echo "
---------------------ENTITY NAME--------------------------
" >> "$MEDTR"

cat ../Medicago/truncatula/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$MEDTR"

echo "
---------------------ENTITY--------------------------
" >> "$MEDTR"

cat ../Medicago/truncatula/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$MEDTR"

echo "
---------------------DOI--------------------------
" >> "$MEDTR"

cat ../Medicago/truncatula/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$MEDTR"

echo "
---------------------PMID--------------------------
" >> "$MEDTR" 

cat ../Medicago/truncatula/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$MEDTR"


############################################
########## Phaseolus vulgaris  ############
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$PHAVU"

cat ../Phaseolus/vulgaris/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$PHAVU"


echo "
---------------------ENTITY NAME--------------------------
" >> "$PHAVU"

cat ../Phaseolus/vulgaris/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$PHAVU"

echo "
---------------------ENTITY--------------------------
" >> "$PHAVU"

cat ../Phaseolus/vulgaris/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$PHAVU"

echo "
---------------------DOI--------------------------
" >> "$PHAVU"

cat ../Phaseolus/vulgaris/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$PHAVU"

echo "
---------------------PMID--------------------------
" >> "$PHAVU" 

cat ../Phaseolus/vulgaris/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$PHAVU"

############################################
############## Pisum sativum  ##############
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$PISSA"

cat ../Pisum/sativum/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$PISSA"


echo "
---------------------ENTITY NAME--------------------------
" >> "$PISSA"

cat ../Pisum/sativum/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$PISSA"

echo "
---------------------ENTITY--------------------------
" >> "$PISSA"

cat ../Pisum/sativum/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$PISSA"

echo "
---------------------DOI--------------------------
" >> "$PISSA"

cat ../Pisum/sativum/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$PISSA"

echo "
---------------------PMID--------------------------
" >> "$PISSA" 

cat ../Pisum/sativum/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$PISSA"

############################################
############## Vicia faba  ##############
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$VICFA"

cat ../Vicia/faba/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$VICFA"


echo "
---------------------ENTITY NAME--------------------------
" >> "$VICFA"

cat ../Vicia/faba/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$VICFA"

echo "
---------------------ENTITY--------------------------
" >> "$VICFA"

cat ../Vicia/faba/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$VICFA"

echo "
---------------------DOI--------------------------
" >> "$VICFA"

cat ../Vicia/faba/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$VICFA"

echo "
---------------------PMID--------------------------
" >> "$VICFA" 

cat ../Vicia/faba/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$VICFA"

############################################
############## Vigna radiata  ##############
############################################


echo "
---------------------GENE MODEL FULL ID--------------------------
" >> "$VIGRA"

cat ../Vigna/radiata/studies/*.yml \
    | grep 'gene_model_full_id' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort -n \
    >> "$VIGRA"


echo "
---------------------ENTITY NAME--------------------------
" >> "$VIGRA"

cat ../Vigna/radiata/studies/*.yml \
    | grep 'entity_name' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$VIGRA"

echo "
---------------------ENTITY--------------------------
" >> "$VIGRA"

cat ../Vigna/radiata/studies/*.yml \
    | grep 'entity' \
    | cut -d ":" -f 2,3 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq -c \
    | sort -nr \
    >> "$VIGRA"

echo "
---------------------DOI--------------------------
" >> "$VIGRA"

cat ../Vigna/radiata/studies/*.yml \
    | grep 'doi' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$VIGRA"

echo "
---------------------PMID--------------------------
" >> "$VIGRA" 

cat ../Vigna/radiata/studies/*.yml \
    | grep 'pmid' \
    | cut -d ":" -f 2 \
    | sed 's/^[[:space:]]*//' \
    | sort \
    | uniq
    >> "$VIGRA"


import yaml


def gene_model_full_id_finder(tsv_path, yaml_path, output_path):
    """# finds gene_model_full_id in tsv file based on gene_model_pub_name and adds it to the yaml file"""
    with open(tsv_path, 'r') as tsv_file:
        # Open the YAML file and load its contents as separate Python objects
        with open(yaml_path, 'r') as file:
            documents = yaml.load_all(file, Loader=yaml.Loader)
            tsv_file_read = tsv_file.read()
            output_data = []
            for document in documents:
                # Process each YAML document delimited by '---'
                gene_model_pub_name = document['gene_model_pub_name']
                for row in tsv_file_read.split('\n'):
                    items = row.split('\t')
                    for item in items:
                        if gene_model_pub_name in item:
                            gene_model_full_id = item
                            document['gene_model_full_id'] = gene_model_full_id
                output_data.append(document)

            # Write the output data to outfile.yml
            with open(output_path, 'w') as outfile:
                yaml.dump_all(output_data, outfile)


def get_gene_model_full_id_dictionary(tsv_path, yaml_path):
    """returns a dictionary of gene_model_pub_name:gene_model_full_id"""
    with open(tsv_path, 'r') as tsv_file:
        # Open the YAML file and load its contents as separate Python objects
        with open(yaml_path, 'r') as file:
            documents = yaml.load_all(file, Loader=yaml.Loader)
            tsv_file_read = tsv_file.read()
            output_data = {}
            for document in documents:
                # Process each YAML document delimited by '---'
                gene_model_pub_name = document['gene_model_pub_name']
                for row in tsv_file_read.split('\n'):
                    items = row.split('\t')
                    for item in items:
                        if gene_model_pub_name in item:
                            gene_model_full_id = item
                            output_data[gene_model_pub_name] = gene_model_full_id
            return output_data


GLYMA_YAML_PATH = 'FILE.traits.yml'
GLYMA_TSV_PATH = 'Glycine.pan3.YWTW.clust.tsv'

# find the gene model full id in the tsv file for GLYMA
gene_model_full_id_finder(GLYMA_TSV_PATH, GLYMA_YAML_PATH, 'g_outfile.yml')


# find the gene model full id in the tsv file for Medicago

# MEDICAGO_YAML_PATH = 'wip_steven/Oellrich_Walls_2015_medtr.medtr.traits.yml'
# MEDICAGO_TSV_PATH = 'Medicago.pan1.XXQ6.clust.tsv'

# gmfi_finder(MEDICAGO_TSV_PATH, MEDICAGO_YAML_PATH, 'm_outfile.yml')

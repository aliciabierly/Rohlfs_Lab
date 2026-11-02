Use Clair3 model to find variants (model: r941_prom_sup_g5014) -- takes into account R9.4.1 chemistry and SUP used to create cram files.

Was made for Guppy5, but recommended for Guppy6 because the models are not too different

This will give us .vcf with SNP/variant information

# create virtual environment
conda create -n clair3_env -c conda-forge -c bioconda -y clair3

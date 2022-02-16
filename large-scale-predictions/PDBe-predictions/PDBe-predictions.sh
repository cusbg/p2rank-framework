#!/bin/bash

# Set up P2Rank
cp ../p2rank_2.4-beta.3.tar.gz .
tar xzf p2rank_2.4-beta.3.tar.gz
rm p2rank_2.4-beta.3.tar.gz
cd p2rank_2.4-beta.3/
sed -i 's/2048m/16G/' prank
rm -r config/ models/
cp --recursive ../../model-training/p2rank_2.4-beta.3/config/ .
cp --recursive ../../model-training/p2rank_2.4-beta.3/models/ .

# Download the PDB archive (see https://www.wwpdb.org/ftp/pdb-ftp-sites)
mkdir datasets
cd datasets/
rsync -rlpt -v -z --delete \
rsync.ebi.ac.uk::pub/databases/pdb/data/structures/divided/pdb/ \
./pdb > download-pdb.log

# Extract sequences in FASTA format
for f in $(grep .ent.gz download-pdb.log)
do
	echo pdb/${f} >> pdb.ds
done
cd ../
./prank analyze fasta-masked datasets/pdb.ds -o datasets/fastas/ &> datasets/fastas.log

# Find unique sequences and split them into chunks for parallel processing
cd datasets/
../../generate_chunks.py > chunks.log

# Compute conservation scores for individual chunk sequences
# ...

# Unpack the conservation score files
../../unpack_homs.py

# Run the predictions
mkdir predictions
cd ../
for configuration in conservation_hmm default
do
	./prank eval-predict datasets/pdb.ds -c ${configuration}.groovy -conservation_dirs homs/ -o datasets/predictions/${configuration}/ -threads 16 &> datasets/predictions/${configuration}.log
done

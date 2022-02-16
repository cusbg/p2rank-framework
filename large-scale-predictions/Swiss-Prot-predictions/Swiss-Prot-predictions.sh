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

# Download the predicted structures
mkdir datasets
cd datasets/
mkdir swissprot
cd swissprot/
wget -q https://ftp.ebi.ac.uk/pub/databases/alphafold/latest/swissprot_pdb_v2.tar
tar xf swissprot_pdb_v2.tar
rm swissprot_pdb_v2.tar
cd ../
for f in swissprot/*.pdb.gz
do
	echo ${f} >> swissprot.ds
done

# Extract sequences in FASTA format
cd ../
./prank analyze fasta-masked datasets/swissprot.ds -o datasets/fastas/ &> datasets/fastas.log

# Find unique sequences and split them into chunks for parallel processing
cd datasets/
../../generate_chunks.py > chunks.log

# Compute conservation scores for individual chunk sequences
# ...

# Unpack the conservation score files
../../../PDBe-predictions/unpack_homs.py

# Run the predictions
mkdir predictions
cd ../
for configuration in alphafold_conservation_hmm alphafold
do
        ./prank eval-predict datasets/swissprot.ds -c ${configuration}.groovy -conservation_dirs homs/ -o datasets/predictions/${configuration}/ -threads 16 &> datasets/predictions/${configuration}.log
done

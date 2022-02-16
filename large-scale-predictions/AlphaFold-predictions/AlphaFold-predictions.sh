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
for proteome_ID in $(cat ../../proteome_IDs)
do
	mkdir ${proteome_ID}
	cd ${proteome_ID}/
	wget -q http://ftp.ebi.ac.uk/pub/databases/alphafold/${proteome_ID}.tar
	tar xf ${proteome_ID}.tar
	rm ${proteome_ID}.tar
	cd ../
	for f in ${proteome_ID}/*.pdb.gz
	do
		echo ${f} >> alphafold.ds
	done
done

# Extract sequences in FASTA format
cd ../
./prank analyze fasta-masked datasets/alphafold.ds -o datasets/fastas/ &> datasets/fastas.log

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
	./prank eval-predict datasets/alphafold.ds -c ${configuration}.groovy -conservation_dirs homs/ -o datasets/predictions/${configuration}/ -threads 16 &> datasets/predictions/${configuration}.log
done

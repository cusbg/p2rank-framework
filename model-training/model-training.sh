#!/bin/bash

# Download and set up P2Rank
wget https://github.com/rdk/p2rank/releases/download/2.3/p2rank_2.3.tar.gz
tar xzf p2rank_2.3.tar.gz
rm p2rank_2.3.tar.gz
cd p2rank_2.3/
sed -i 's/2048m/8G/' prank

# Download p2rank-datasets
git clone https://github.com/rdk/p2rank-datasets.git

# Set up conservation calculations (see conservation_hmm README for requirements)
mkdir conservation
cd conservation/
wget https://raw.githubusercontent.com/cusbg/prankweb/master/conservation/conservation_hmm/conservation_hmm.py
chmod +x conservation_hmm.py
mkdir databases fastas homs
cd databases/
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gunzip uniprot_sprot.fasta.gz
wget https://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref50/uniref50.fasta.gz
gunzip uniref50.fasta.gz
wget https://ftp.uniprot.org/pub/databases/uniprot/relnotes.txt
cd ../

# Prepare fasta files
cd ../
for dataset in chen11 coach420 holo4k joined
do
	./prank analyze fasta-masked p2rank-datasets/${dataset}.ds -o conservation/fastas/${dataset} &> conservation/fastas/${dataset}.log
done

# Calculate conservations
cd conservation/
for dataset in chen11 coach420 holo4k joined
do
	for database in uniprot_sprot uniref50
	do
		mkdir -p homs/${dataset}/${database}
		for fasta_file in fastas/${dataset}/*.fasta
		do
			cp "${fasta_file}" no_spaces.fasta
			mkdir tmp_dir
			./conservation_hmm.py no_spaces.fasta databases/${database}.fasta tmp_dir/ homs/${dataset}/${database}/"$(basename "${fasta_file}")".hom --max_seqs 1000 &> homs/${dataset}/${database}/"$(basename "${fasta_file}")".log
			rm no_spaces.fasta
			rm -r tmp_dir/
		done
	done
done

# Prepare masked conservation files
wget https://raw.githubusercontent.com/cusbg/prankweb/master/conservation/conservation_hmm/examples/mask_ic_file.py
chmod +x mask_ic_file.py
cd homs/
for dataset in chen11 coach420 holo4k joined
do
	cd ${dataset}/
	for database in uniprot_sprot uniref50
	do
		cd ${database}/
		for max_freqgap in 30 50 70 90
		do
			mkdir -p masked_${max_freqgap}
			for hom_file in *.hom
			do
				../../../mask_ic_file.py "${hom_file}" "${hom_file}".freqgap masked_${max_freqgap}/"$(basename "${hom_file}" .hom)".masked_${max_freqgap}.hom 0.${max_freqgap} -1000.0
			done
		done
		cd ../
	done
	cd ../
done

# Fix filenames containing spaces
for dataset in joined
do
	cd ${dataset}/
	for database in uniprot_sprot uniref50
	do
		cd ${database}/
		for max_freqgap in 30 50 70 90
		do
			cd masked_${max_freqgap}/
			cp ../../../../../../fix_filenames.py .
			./fix_filenames.py
			rm fix_filenames.py
			cd ../
		done
		cd ../
	done
	cd ../
done

# Prepare new models
cd ../../
cp ../conservation_hmm.groovy config/
for database in uniprot_sprot uniref50
do
	for max_freqgap in 30 50 70 90
	do
		./prank traineval -t p2rank-datasets/chen11.ds -e p2rank-datasets/joined.ds -c conservation_hmm.groovy -conservation_dirs "(../conservation/homs/chen11/${database}/masked_${max_freqgap}, ../conservation/homs/joined/${database}/masked_${max_freqgap})" -delete_models false -loop 10 -o new_models/${database}/masked_${max_freqgap} -threads 4
#		./prank traineval -t p2rank-datasets/chen11-fpocket.ds -e p2rank-datasets/joined.ds -c conservation_hmm.groovy -conservation_dirs "(../conservation/homs/chen11/${database}/masked_${max_freqgap}, ../conservation/homs/joined/${database}/masked_${max_freqgap})" -delete_models false -loop 10 -o new_models/${database}/masked_${max_freqgap} -threads 4
	done
done

# Evaluate the new models
for dataset in coach420 holo4k
do
	for database in uniprot_sprot uniref50
	do
		for max_freqgap in 30 50 70 90
		do
			for seed in $(seq 42 1 51)
			do
				./prank eval-predict p2rank-datasets/${dataset}.ds -c conservation_hmm.groovy -conservation_dirs ../conservation/homs/${dataset}/${database}/masked_${max_freqgap} -m new_models/${database}/masked_${max_freqgap}/runs/seed.${seed}/FastRandomForest.model -o new_models_evaluation/${dataset}/${database}/masked_${max_freqgap}/runs/seed.${seed} -threads 4
			done
		done
	done
done

# Rename the selected model
cp new_models/uniref50/masked_50/runs/seed.45/FastRandomForest.model new_models/uniref50/masked_50/runs/seed.45/conservation_hmm.model

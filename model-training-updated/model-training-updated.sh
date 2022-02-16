#!/bin/bash

# Set up P2Rank
cp ../p2rank_2.4-beta.3.tar.gz .
tar xzf p2rank_2.4-beta.3.tar.gz
rm p2rank_2.4-beta.3.tar.gz
cd p2rank_2.4-beta.3/
sed -i 's/2048m/16G/' prank

# Download p2rank-datasets
git clone https://github.com/rdk/p2rank-datasets.git &> p2rank-datasets.log

# Set up conservation calculations
mkdir conservation
cd conservation/
mkdir fastas homs
cd ../

# Prepare fasta files
for dataset in chen11 coach420 holo4k joined
do
	./prank analyze fasta-masked p2rank-datasets/${dataset}.ds -o conservation/fastas/${dataset} &> conservation/fastas/${dataset}.log
done

# Calculate conservations
cd conservation/
for dataset in chen11 coach420 holo4k joined
do
	for database in uniref50
	do
		mkdir -p homs/${dataset}/${database}
		for fasta_file in fastas/${dataset}/*.fasta
		do
			cp "${fasta_file}" no_spaces.fasta
			mkdir tmp_dir
			../../../PDBe-predictions/compute-conservation/compute-conservation.py no_spaces.fasta ../../../PDBe-predictions/compute-conservation/${database}.fasta tmp_dir/ homs/${dataset}/${database}/"$(basename "${fasta_file}")".hom &> homs/${dataset}/${database}/"$(basename "${fasta_file}")".log
			rm no_spaces.fasta
			rm -r tmp_dir/
		done
	done
done

# Prepare new models
cd ../
for configuration in alphafold_conservation_hmm alphafold conservation_hmm
do
	rm -f models/${configuration}.model
	rm -f models/score/${configuration}_*.json
	rm -f models/score/residue/${configuration}_*.json
	sed 's#    model#\/\/    model#' config/${configuration}.groovy | sed 's#    zscoretp#\/\/    zscoretp#' | sed 's#    probatp#\/\/    probatp#' > config/${configuration}_training.groovy
	for database in uniref50
	do
		./prank traineval -t p2rank-datasets/chen11.ds -e p2rank-datasets/joined.ds -c ${configuration}_training.groovy -conservation_dirs "(../conservation/homs/chen11/${database}, ../conservation/homs/joined/${database})" -delete_models false -loop 20 -o new_models/${configuration}/${database} -threads 16
	done
done

for configuration in default
do
	for database in uniref50
	do
		./prank traineval -t p2rank-datasets/chen11.ds -e p2rank-datasets/joined.ds -c ${configuration}.groovy -delete_models false -loop 20 -o new_models/${configuration}/${database} -threads 16
	done
	rm -f models/${configuration}.model
#	rm -f models/score/${configuration}_*.json
#	rm -f models/score/residue/p2rank_${configuration}_*.json
done

cp new_models/alphafold_conservation_hmm/uniref50/runs/seed.46/FastRandomForest.model models/alphafold_conservation_hmm.model
cp new_models/alphafold/uniref50/runs/seed.49/FastRandomForest.model models/alphafold.model
cp new_models/conservation_hmm/uniref50/runs/seed.45/FastRandomForest.model models/conservation_hmm.model
cp new_models/default/uniref50/runs/seed.58/FastRandomForest.model models/default.model

cp config/default.groovy config/default_training.groovy
mkdir transformers
for configuration in alphafold_conservation_hmm alphafold conservation_hmm default
do
	./prank eval-predict p2rank-datasets/holo4k.ds -c ${configuration}_training.groovy -conservation_dirs ../conservation/homs/holo4k/uniref50 -m ${configuration}.model -o transformers/${configuration} -threads 16 -train_score_transformers "(ProbabilityScoreTransformer, ZscoreTpTransformer)" -train_score_transformers_for_residues true -visualizations false &> transformers/${configuration}.log
	cp transformers/${configuration}/score/ProbabilityScoreTransformer.json models/score/${configuration}_ProbabilityScoreTransformer.json
	cp transformers/${configuration}/score/ZscoreTpTransformer.json models/score/${configuration}_ZscoreTpTransformer.json
	cp transformers/${configuration}/residue-score/ProbabilityScoreTransformer.json models/score/residue/${configuration}_ProbabilityScoreTransformer.json
	cp transformers/${configuration}/residue-score/ZscoreTpTransformer.json models/score/residue/${configuration}_ZscoreTpTransformer.json
done

sed -i 's/default_probatp.json/default_ProbabilityScoreTransformer.json/' config/default.groovy
sed -i 's/default_zscoretp.json/default_ZscoreTpTransformer.json/' config/default.groovy
sed -i 's/p2rank_default_proba.json/default_ProbabilityScoreTransformer.json/' config/default.groovy
sed -i 's/p2rank_default_zscore.json/default_ZscoreTpTransformer.json/' config/default.groovy

# Evaluate the new models
for configuration in alphafold_conservation_hmm alphafold conservation_hmm default
do
	for dataset in coach420 holo4k
	do
	./prank eval-predict p2rank-datasets/${dataset}.ds -c ${configuration}.groovy -conservation_dirs ../conservation/homs/${dataset}/uniref50 -o new_models_evaluation/${configuration}/${dataset} -threads 16
	done
done

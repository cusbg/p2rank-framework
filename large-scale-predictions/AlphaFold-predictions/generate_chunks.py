#!/usr/bin/env python3

from glob import glob
from os import mkdir
from shutil import copy

CHUNK_SIZE = 100


def generate_sequence_to_legacy_fasta_file_mapping():
    sequence_to_legacy_fasta_file_mapping = dict()
    legacy_fasta_files = glob('../../../../P2Rank/AlphaFold-predictions/p2rank_2.3.1/datasets/chunks/chunk_*/*.fasta')
    for legacy_fasta_file in legacy_fasta_files:
        with open(legacy_fasta_file) as f:
            next(f)
            sequence = next(f).strip()
            sequence_to_legacy_fasta_file_mapping[sequence] = legacy_fasta_file
    return sequence_to_legacy_fasta_file_mapping


sequence_to_legacy_fasta_file_mapping = generate_sequence_to_legacy_fasta_file_mapping()

input_fasta_files = glob('fastas/*.fasta')

sequence_to_ids = dict()

for input_fasta_file in input_fasta_files:
    with open(input_fasta_file) as f:
        next(f)
        sequence = next(f).strip()
        if sequence in sequence_to_ids:
            sequence_to_ids[sequence].append(input_fasta_file.split('/')[1][:-6])
        else:
            sequence_to_ids[sequence] = []
            sequence_to_ids[sequence].append(input_fasta_file.split('/')[1][:-6])

sequences = sorted(sequence_to_ids)
sequence_chunks = (sequences[i:i + CHUNK_SIZE] for i in range(0, len(sequences), CHUNK_SIZE))

mkdir('chunks/')
for chunk_number, chunk_sequences in enumerate(sequence_chunks):
    mkdir('chunks/chunk_{}/'.format(chunk_number))
    mkdir('chunks/chunk_{}/conservation/'.format(chunk_number))
    for sequence_number, sequence in enumerate(chunk_sequences):
        with open('chunks/chunk_{}/sequence_{}.fasta'.format(chunk_number, sequence_number), mode='w') as f:
            print('chunks/chunk_{}/sequence_{}.fasta'.format(chunk_number, sequence_number), ';'.join(sequence_to_ids[sequence]), sep='\t')
            f.write('>' + ';'.join(sequence_to_ids[sequence]) + '\n' + sequence + '\n')
            if sequence in sequence_to_legacy_fasta_file_mapping:
                copy(sequence_to_legacy_fasta_file_mapping[sequence].replace('/sequence_', '/conservation/sequence_') + '.conservation', 'chunks/chunk_{}/conservation/sequence_{}.fasta.conservation'.format(chunk_number, sequence_number))
                copy(sequence_to_legacy_fasta_file_mapping[sequence].replace('/sequence_', '/conservation/sequence_') + '.conservation.unmasked', 'chunks/chunk_{}/conservation/sequence_{}.fasta.conservation.unmasked'.format(chunk_number, sequence_number))
                copy(sequence_to_legacy_fasta_file_mapping[sequence].replace('/sequence_', '/conservation/sequence_') + '.conservation.unmasked.freqgap', 'chunks/chunk_{}/conservation/sequence_{}.fasta.conservation.unmasked.freqgap'.format(chunk_number, sequence_number))

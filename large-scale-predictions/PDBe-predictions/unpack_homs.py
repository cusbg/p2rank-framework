#!/usr/bin/env python3

from glob import glob
from os import mkdir
from shutil import copy

conservation_files = glob('chunks/chunk_*/conservation/*.conservation')

fasta_file_to_pdb_chain_ids = dict()

with open('chunks.log') as f:
    for line in f:
        fasta_file, pdb_chain_ids = line.strip().split()
        fasta_file_to_pdb_chain_ids[fasta_file] = pdb_chain_ids.split(';')

mkdir('homs')

for conservation_file in conservation_files:
    for pdb_chain_id in fasta_file_to_pdb_chain_ids[conservation_file.replace('/conservation', '').replace('.conservation', '')]:
        copy(conservation_file, 'homs/{}.hom'.format(pdb_chain_id))

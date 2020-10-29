# P2Rank framework

P2Rank framework is a loosely coupled framework of several components for ligand-binding site prediction. P2Rank is a ligand binding site prediction tools utilizing machine learning to identify sites on the surface on the input 3D protein structure capable of binding an unspecified small molecule. 

The purpose of this document is to be the central entry point to the project containing links to the individual projects, including references to documentation, datasets, etc.

## P2Rank applications
- [Command line app](https://github.com/rdk/p2rank) enabling users to run high-throughput analysis
- [Web app](https://p2rank.cz) supporting online detection and their visual inspection, including download of the results to [PyMol](https://pymol.org/)

## P2Rank modules

- [P2Rank code repository](https://github.com/rdk/p2rank) - the main app, serving also as the backend to the web
- [PrankWeb code repository](https://github.com/cusbg/prankweb) - code for the web frontend
- [Conservation pipeline](https://github.com/cusbg/sequence-conservation) - pipeline to compute conservation which is used as one of the P2rank features
- [PDBe-KB integration](https://github.com/cusbg/p2rank-pdbe-kb) - code used to share predictions with [PDBe-KB](https://www.ebi.ac.uk/pdbe/pdbe-kb)

## Documentation

- The [framework architecture](https://github.com/cusbg/prankweb/wiki/PrankWeb-Architecture) from the point of view of the web server

## Datasets
- https://github.com/rdk/p2rank-datasets

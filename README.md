# P2Rank framework

P2Rank is a ligand binding site prediction tools utilizing machine learning to identify sites on the surface on the input 3D protein structure capable of binding an unspecified small molecule. P2Rank framework is a loosely coupled framework of several components with P2Rank at its core.

The purpose of this repository is to be the central entry point to the project containing links to the individual projects, including references to documentation, datasets, etc.

## P2Rank applications
- [Command line app](https://github.com/rdk/p2rank) enabling users to run high-throughput analysis
- [Web app](https://p2rank.cz) supporting online detection and their visual inspection, including download of the results to [PyMol](https://pymol.org/)

## P2Rank modules

- [P2Rank code repository](https://github.com/rdk/p2rank) - the main app, serving also as the backend to the web
- [PrankWeb code repository](https://github.com/cusbg/prankweb) - code for the web frontend
- [Old conservation pipeline](https://github.com/cusbg/sequence-conservation) - pipeline used to compute conservation which is used as one of the P2rank features. In PrankWeb3 this is replaced by HMM-based conservation available in the [PrankWeb repo](https://github.com/cusbg/prankweb/tree/main/conservation)
- [PDBe-KB integration](https://github.com/cusbg/p2rank-pdbe-kb) - code used to share predictions with [PDBe-KB](https://www.ebi.ac.uk/pdbe/pdbe-kb)

## Documentation

- [Wiki](https://github.com/cusbg/p2rank-framework/wiki) in this repository
- [P2Rank tutorials](https://github.com/rdk/p2rank/tree/develop/documantation) available for some more advanced topics (such as hyperparameter optimization) related to P2Rank backend (some information might overlap with the docs available in this repo)

## Datasets
- protein-ligand
  - https://github.com/rdk/p2rank-datasets
- protein-DNA
  - https://github.com/cusbg/p2rank-data-dna

## Publications
- Lukáš Polák, Petr Škoda, Kamila Riedlová, Radoslav Krivák, Marian Novotný and David Hoksza. [PrankWeb 4: a modular web server for protein–ligand binding site prediction and downstream analysis](https://doi.org/10.1093/nar/gkaf421). Nucleic Acids Research. May 2025
- Dávid Jakubec, Petr Škoda, Radoslav Krivák, Marian Novotný and David Hoksza. [PrankWeb 3: accelerated ligand-binding site predictions for experimental and modelled protein structures](https://doi.org/10.1093/nar/gkac389). Nucleic Acids Research. May 2022
- Lukáš Jendele and Radoslav Krivák and Petr Škoda and Marian Novotný and David Hoksza. [PrankWeb: a web server for ligand binding site prediction and visualization](https://academic.oup.com/nar/article/47/W1/W345/5494740?login=true). Nucleic Acids Research. May 2019
- Radoslav Krivák and David Hoksza. [P2Rank: machine learning based tool for rapid and accurate prediction of ligand binding sites from protein structure](https://jcheminf.biomedcentral.com/articles/10.1186/s13321-018-0285-8). Journal of Cheminformatics. Aug 2018

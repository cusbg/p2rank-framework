from conservation_hmm.conservation_hmm import run_conservation_hmm
from conservation_hmm.examples.mask_ic_file import mask_ic_file


def run_conservation_hmm_wrapper(
    fasta_file,
    database_file,
    working_directory,
    target_file,
    max_seqs=1000,
    max_freqgap=0.5,
    mask_string="-1000.0",
):
    weighted_msa_file = run_conservation_hmm(
        fasta_file=fasta_file,
        database_file=database_file,
        working_directory=working_directory,
        target_file=target_file + ".unmasked",
        max_seqs=max_seqs,
    )
    mask_ic_file(
        ic_file=target_file + ".unmasked",
        freqgap_file=target_file + ".unmasked.freqgap",
        target_file=target_file,
        max_freqgap=max_freqgap,
        mask_string=mask_string,
    )
    return weighted_msa_file

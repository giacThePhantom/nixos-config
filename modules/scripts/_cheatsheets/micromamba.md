# micromamba: conda environments

For tools only on bioconda, or a protocol's environment.yml. Otherwise prefer `dvt bio`.

    micromamba create -n qc -c conda-forge -c bioconda fastqc multiqc   # new environment
    micromamba create -n proto -f environment.yml                        # from a file
    micromamba activate qc / micromamba deactivate
    micromamba install -n qc -c conda-forge -c bioconda samtools=1.20   # add (pin versions)
    micromamba run -n qc fastqc reads.fq.gz        # run without activating
    micromamba env list
    micromamba env export -n qc > environment.yml  # record it (commit this)
    micromamba env remove -n qc

Environments live in `~/.local/share/mamba`. Channel order matters: conda-forge, then bioconda.

# Snakemake: workflows

    snakemake -n                       # dry run: what would run, and why
    snakemake --cores 8                # run, 8 cores
    snakemake --cores 8 -p             # also print each shell command
    snakemake results/x.tsv            # build one target (and what it needs)
    snakemake --rerun-incomplete       # after a crash left half-written files
    snakemake --unlock                 # after a crash left the folder locked
    snakemake --forcerun rule_name     # redo a rule and everything after it
    snakemake --dag | dot -Tpdf > dag.pdf      # the graph (dot: `, dot` or graphviz)
    snakemake --lint                   # common mistakes
    snakemake --report report.html     # an HTML report of the last run
    snakemake --configfile .test/config.yaml   # on the small test data

## A rule
    rule align:
        input:  "data/raw/{sample}.fq.gz"
        output: "results/bam/{sample}.bam"
        threads: 8
        log:    "results/logs/align/{sample}.log"
        shell:  "minimap2 -t {threads} -ax sr ref.fa {input} 2> {log} | samtools sort -o {output}"

## On a SLURM cluster (executor plugin)
    snakemake --executor slurm --jobs 50 --default-resources slurm_account=ACCOUNT

Layout: `workflow/Snakefile`, `workflow/rules/*.smk`, `config/config.yaml`.
Keep a long run alive: `pueue add -- snakemake --cores 8`.

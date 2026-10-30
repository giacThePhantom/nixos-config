# Nextflow and nf-core

    # try a pipeline on its test data
    nextflow run nf-core/rnaseq -r 3.14.0 -profile test,docker --outdir results
    nextflow run nf-core/rnaseq -r 3.14.0 -profile apptainer \
        --input samplesheet.csv --genome GRCh38 --outdir results
    nextflow run ... -resume           # continue: finished steps are reused
    nextflow run ... -params-file params.yaml   # parameters in a file (keep it in git)
    nextflow log                       # past runs; `nextflow log RUN -f name,status,exit`
    nextflow clean -f -before RUN      # delete work/ of older runs

- Always pin the pipeline version (`-r`), and keep the command in the README.
- `work/` holds intermediate files and grows fast; `results/` is the output.
- Profiles: `docker` (Podman works through `docker`), `apptainer`/`singularity` (clusters), `test`.
- Reports: `-with-report report.html -with-timeline timeline.html`.
- Pipelines: https://nf-co.re/pipelines; each has a parameter page and a test profile.

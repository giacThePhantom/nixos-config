# Projects

## One environment per project

On most systems you install Python, R and their packages once, for
everything, and sooner or later two projects need different versions and
something breaks. Here each project brings its own: a `flake.nix` file in the
project folder lists what it needs, and entering the folder makes exactly
that available.

```sh
mkdir rnaseq-liver && cd rnaseq-liver
git init
dvt bio
```

`dvt bio` asks what this project needs (`Tab` selects, `Enter` confirms):

| Component | Brings |
| --- | --- |
| `python` | numpy, pandas, scipy, matplotlib, seaborn |
| `biopython` | biopython, pysam |
| `ml` | scikit-learn |
| `singlecell-python` | scanpy, anndata |
| `jupyter` | JupyterLab, with kernels for Python and/or R |
| `r` | R with tidyverse |
| `bioconductor` | GenomicRanges, BiocManager |
| `rnaseq-r` | DESeq2, edgeR, limma |
| `singlecell-r` | Seurat |
| `snakemake` | Snakemake workflows |
| `nextflow` | Nextflow workflows (nf-core) |
| `qc` | fastp, FastQC, MultiQC, seqkit |
| `alignment` | minimap2, bwa-mem2, samtools |
| `rnaseq` | STAR, salmon, featureCounts |
| `variants` | bcftools, bgzip, tabix |
| `intervals` | bedtools |
| `download` | prefetch, fasterq-dump (SRA) |

Or name them directly: `dvt bio python qc snakemake`.

It also lays out the project the standard way: `config/`, `data/raw/`
(never edited, not in git), `workflow/`, `notebooks/`, `results/` (produced by
the workflow, not in git), a `README.md` to fill in and `data/README.md` for
where the data came from. Why, and the rest of the ground rules:
[Good practice](14-good-practice.md).

The first time you `cd` into the project, everything is downloaded (a few
hundred MiB; projects with R may also spend some minutes building packages,
once). From then on, entering the folder is instant, and leaving it puts
your terminal back as it was.

**`download`** compiles NCBI's SRA toolkit on your machine the first time
(some minutes): nixpkgs can't ship it prebuilt because of its licence. If
you're in a hurry, `micromamba create -n sra -c bioconda sra-tools` is
prebuilt. NCBI's `datasets` tool is on bioconda only: `-c bioconda
ncbi-datasets-cli`.

**Changing your mind.** Open `flake.nix`: the components are a list of
`true`/`false` at the top. Anything not in the list goes in `extra` (tools),
`extraPython` or `extraR` (packages); find names on
[search.nixos.org](https://search.nixos.org/packages). Save, and the next
command in that folder has it.

**Reproducibility.** `flake.lock`, next to `flake.nix`, records the exact
version of everything. Commit both with your code: anyone, on any machine
with Nix, gets the same environment, in a month or in five years.
`nix flake update` moves the project to newer versions when you decide.

**Other languages.** `dvt` alone lets you pick from all the templates:
`python`, `r`, `rust`, `go`, `node`, `latex`, `typst`, `jupyter` and more.

## A tool, just once

```sh
, fastqc reads.fq.gz
```

The comma runs any of the 100,000+ tools packaged for Nix without installing
it. Great for trying something, or for a tool you need twice a year.

## Conda and bioconda

Some tools exist only on bioconda, and many protocols come with an
`environment.yml`. micromamba (a fast conda) handles both:

```sh
micromamba create -n qc -f environment.yml    # or: -c conda-forge -c bioconda TOOL
micromamba activate qc
```

Prefer `dvt bio` when you can (it is reproducible and shares downloads
between projects); use micromamba when you must.

## Programs downloaded from the web

Prebuilt Linux programs, pip packages with compiled parts, and conda
packages expect files in places NixOS doesn't use. This system provides
them, so they run as on any other Linux. AppImages too: make the file
executable (`chmod +x App.AppImage`) and run it.

## Containers

**Your project as an image.** A `bio` project can also be built as a
container image, with exactly the tools and versions of its environment
(from `flake.lock`, no Dockerfile to keep in sync):

```sh
nix build .#container          # result: an image file
docker load < result           # or: podman load < result
docker run -it --rm -v "$PWD":/work bio-project
```

Change the image's name in `flake.nix` (`name = "bio-project"`). Push it to
a registry (`docker push`, after tagging) to share it, or convert it for a
cluster that runs Apptainer:
`apptainer build bio-project.sif docker-archive://result`.

**Running containers here.** Docker images (Podman, rootless, no daemon;
`docker` and `docker compose` work too) and Apptainer images from BioContainers or nf-core need
the optional `containers` feature (see
[Applications](08-applications.md#optional-apps)). Building an image with
`nix build` needs nothing extra.

Next: [Making it yours](11-making-it-yours.md).

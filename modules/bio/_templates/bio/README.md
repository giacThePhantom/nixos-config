# Project title

One or two sentences: the question this project answers.

## Reproduce it

```sh
git clone <this repository> && cd <it>
direnv allow                 # or: nix develop
snakemake --cores 8          # or: nextflow run ...; see workflow/
```

Everything in `results/` is produced by the workflow from `data/raw/` and
`config/`; delete it and run again to get the same results.

## Layout

| Folder | What | In git |
| --- | --- | --- |
| `config/` | parameters and the sample sheet | yes |
| `data/raw/` | input data as received, read-only; where it came from: `data/README.md` | no |
| `workflow/` | the pipeline (Snakefile or main.nf), its rules and scripts | yes |
| `notebooks/` | exploration, numbered (`01-qc.ipynb`) | yes, without outputs |
| `results/` | everything the workflow produces | no |

The environment (tools and versions) is `flake.nix` + `flake.lock`; a
container image of it: `nix build .#container`.

## Data

See `data/README.md`.

## Authors, licence, citation

Who did what; the licence of the code (e.g. MIT) and of the text; how to
cite (a Zenodo DOI once released).

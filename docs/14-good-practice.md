# Good practice for projects

Ground rules for bioinformatics projects that someone else (or you, in two
years, for the reviewers) can understand, rerun and trust. They follow the
field's common references: Noble's *A Quick Guide to Organizing
Computational Biology Projects*, Wilson et al.'s *Good Enough Practices in
Scientific Computing*, the Snakemake and nf-core conventions, and the FAIR
principles. `dvt bio` already sets most of this up.

## The ten rules

**1. One project, one folder, one git repository.** A question gets its own
repository, created with `dvt bio`. Shared code becomes its own repository
(or package), not a copy.

**2. Raw data is read-only.** What you receive or download goes in
`data/raw/` and is never edited. `data/README.md` records where each file
came from (accession or URL, date) and `data/MD5SUMS` its checksum. Raw data
is not in git: too big, and you can download it again.

**3. Everything else is produced by code.** Every file in `results/` comes
from a script or the workflow. Delete `results/`, run the workflow, get the
same files back. No manual steps; if one is unavoidable, write it down in the
README, exactly.

**4. The environment is part of the project.** `flake.nix` and `flake.lock`
are committed: they are the exact tools and versions. Don't install things
outside them for the analysis. For a cluster or a collaborator without Nix,
`nix build .#container` gives the same environment as an image (see
[Projects](10-projects.md#containers)).

**5. Use a workflow manager.** Anything you run more than once (or on more
than one sample) belongs in Snakemake or Nextflow, not in a series of
commands in your shell history. Before writing a pipeline, check
[nf-core](https://nf-co.re/pipelines) and the
[Snakemake workflow catalog](https://snakemake.github.io/snakemake-workflow-catalog/):
a maintained, published pipeline beats your own.

**6. Parameters and samples live in `config/`.** Thresholds, reference
genome versions and the sample sheet (`config/samples.tsv`) are data, not
code. No absolute paths (`/home/you/...`) in code: paths are relative to the
project, or come from `config/`.

**7. Commit small, often, with messages that say why.** "Filter reads below
Q20 (reviewer 2)" beats "update". Never commit data, results or secrets
(passwords, tokens; `.gitignore` already keeps data and results out). Tag
the version behind a submission: `git tag v1.0-submitted`.

**8. Notebooks explore, workflows produce.** Notebooks are numbered
(`01-qc.ipynb`, `02-de.ipynb`) and run top to bottom ("Restart & Run All")
before a commit. Clear their outputs before committing. When a notebook's
analysis matters, move it into a script the workflow runs.

**9. Make chance reproducible.** Set random seeds (sampling, clustering,
t-SNE/UMAP, machine learning) and write them in `config/`. Versions are
already recorded by `flake.lock`.

**10. Test on something small.** Keep a tiny test dataset (a few thousand
reads) in `.test/`, and run the workflow on it before the real data:
`snakemake --configfile .test/config.yaml`. `snakemake --lint` catches
common workflow mistakes; a formatter (`ruff format`, `styler`) keeps code
readable.

## Naming

- Lowercase, no spaces: `de_results_liver.tsv`, not `DE Results (final).xlsx`.
- Dates as `2026-10-30` (they sort correctly).
- One identifier per sample, used everywhere: file names, sample sheet,
  plots.
- No `final`, `final2`, `new`: git keeps the versions.

## Writing it down

- **README.md** (the template has one): the question, how to reproduce,
  where the data comes from, who did what.
- **A lab notebook**: decisions and why (`docs/notebook.md`, dated entries).
  "Excluded sample 7: RIN 4.2" is invaluable at review time.
- **sessionInfo / versions**: the lock file has them; for a methods section,
  `nix flake metadata` shows the exact nixpkgs revision.

## Sharing and publishing

- **Raw data**: deposit it in the public archive for its kind (SRA/ENA for
  reads, GEO for expression, PRIDE for proteomics) before submission; journals
  ask for accessions.
- **Code**: a public repository (GitHub, GitLab, your institution's), archived
  with a DOI on [Zenodo](https://zenodo.org) at submission.
- **Environment**: the flake and its lock are in the repository; attach the
  container image if reviewers need to run it without Nix.
- **Licences**: MIT or Apache-2.0 for code, CC BY 4.0 for text and figures,
  unless your institution says otherwise.

## Sensitive data

Human genomes and health data are personal data under the GDPR. Keep them
only on storage your institution approves for them (often the cluster, not
your laptop), never in personal cloud storage or in git, and follow your
project's data management plan. Share results, not individual-level data,
unless the consent and the DMP allow it.

## Backups

The 3-2-1 rule: 3 copies, on 2 different media, 1 elsewhere. Your code is
in git and its remote; your raw data is in the archive or on the cluster;
what remains (notes, drafts, figures in progress) is what the optional
`backup` feature is for ([Research tools](09-research.md#backups)).

## The check before you call it done

On another machine (or a fresh clone in `/tmp`):

```sh
git clone <repository> check && cd check
direnv allow
snakemake -n          # the plan: does it find every input?
snakemake --cores 8   # does it produce the same results?
```

If that works without asking you anything, the project is reproducible.

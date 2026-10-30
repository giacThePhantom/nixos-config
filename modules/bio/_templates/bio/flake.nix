{
  # A bioinformatics project's environment, built from the components
  # switched on below: `dvt bio` asks which ones you need, and you can flip
  # any of them here later. `cd` into the project and direnv loads it (the
  # first time downloads it; later it is instant). Anything missing: add it
  # to `extra` (or `extraPython`, `extraR`), names from https://search.nixos.org
  # (Python packages as python3Packages.NAME, R/Bioconductor as rPackages.NAME).
  # flake.lock keeps every version fixed, so the analysis reproduces;
  # `nix flake update` moves to newer ones.
  description = "Bioinformatics project environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      # Components: true to include
      use = {
        python = false; # Python: numpy, pandas, scipy, matplotlib, seaborn
        biopython = false; # Python: biopython, pysam (sequences, BAM/VCF)
        ml = false; # Python: scikit-learn
        singlecell-python = false; # Python: scanpy, anndata
        jupyter = false; # JupyterLab, with a kernel for Python and/or R
        r = false; # R: tidyverse
        bioconductor = false; # R: Bioconductor basics (GenomicRanges, BiocManager)
        rnaseq-r = false; # R: DESeq2, edgeR, limma
        singlecell-r = false; # R: Seurat
        snakemake = false; # Snakemake workflows
        nextflow = false; # Nextflow workflows (nf-core)
        qc = false; # fastp, FastQC, MultiQC, seqkit
        alignment = false; # minimap2, bwa-mem2, samtools
        rnaseq = false; # STAR, salmon, subread (featureCounts)
        variants = false; # bcftools, htslib (bgzip, tabix)
        intervals = false; # bedtools
        download = false; # SRA: prefetch, fasterq-dump (NCBI datasets: via micromamba)
      };

      name = "bio-project"; # the container image's name (`nix build .#container`)

      # Language servers for the editor (Python: basedpyright, ruff; R:
      # languageserver), in the shell only, never in the container
      languageServers = true;

      extra = pkgs: [ ]; # more tools, e.g. pkgs.mafft
      extraPython = ps: [ ]; # more Python packages, e.g. ps.polars
      extraR = rp: [ ]; # more R packages, e.g. rp.ggrepel

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              # NCBI's SRA toolkit (and its library) is public domain, but its
              # own licence counts as "unfree" for nixpkgs: allow just those
              config.allowUnfreePredicate =
                p:
                builtins.elem (nixpkgs.lib.getName p) [
                  "sratoolkit"
                  "ncbi-vdb"
                ];
            }
          )
        );
      # The environment: { packages, shellHook } for one system; `editing`
      # adds the language servers (the shell has them, the container not)
      environment =
        pkgs: editing:
        let
          inherit (nixpkgs.lib) optional optionals;
          withR = use.r || use.bioconductor || use.rnaseq-r || use.singlecell-r;
          withPython = use.python || use.biopython || use.ml || use.singlecell-python || use.jupyter;
          servers = editing && languageServers;

          python = pkgs.python3.withPackages (
            ps:
            optionals use.python [
              ps.numpy
              ps.pandas
              ps.scipy
              ps.matplotlib
              ps.seaborn
            ]
            ++ optionals use.biopython [
              ps.biopython
              ps.pysam
            ]
            ++ optional use.ml ps.scikit-learn
            ++ optionals use.singlecell-python [
              ps.scanpy
              ps.anndata
            ]
            ++ optionals use.jupyter [
              ps.jupyterlab
              ps.ipykernel
            ]
            ++ extraPython ps
          );

          r = pkgs.rWrapper.override {
            packages =
              with pkgs.rPackages;
              optional use.r tidyverse
              ++ optionals use.bioconductor [
                BiocManager
                GenomicRanges
              ]
              ++ optionals use.rnaseq-r [
                DESeq2
                edgeR
                limma
              ]
              ++ optional use.singlecell-r Seurat
              ++ optional use.jupyter IRkernel
              ++ optional servers languageserver
              ++ extraR pkgs.rPackages;
          };
        in
        {
          packages =
            with pkgs;
            optional withPython python
            ++ optional withR r
            ++ optional use.snakemake snakemake
            ++ optional use.nextflow nextflow
            ++ optionals use.qc [
              fastp
              fastqc
              multiqc
              seqkit
            ]
            ++ optionals use.alignment [
              minimap2
              bwa-mem2
              samtools
            ]
            ++ optionals use.rnaseq [
              star
              salmon
              subread
            ]
            ++ optionals use.variants [
              bcftools
              htslib
            ]
            ++ optional use.intervals bedtools
            ++ optional use.download sratoolkit
            ++ optionals (servers && withPython) [
              basedpyright
              ruff
            ]
            ++ extra pkgs;

          # Jupyter's R kernel: a kernelspec that starts this R with IRkernel
          shellHook = nixpkgs.lib.optionalString (use.jupyter && withR) ''
            export JUPYTER_PATH="${
              pkgs.writeTextDir "share/jupyter/kernels/ir/kernel.json" (
                builtins.toJSON {
                  argv = [
                    "${r}/bin/R"
                    "--slave"
                    "-e"
                    "IRkernel::main()"
                    "--args"
                    "{connection_file}"
                  ];
                  display_name = "R";
                  language = "R";
                }
              )
            }/share/jupyter''${JUPYTER_PATH:+:$JUPYTER_PATH}"
          '';
        };
    in
    {
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell (environment pkgs true);
      });

      # The same environment as a container image, for Docker, Podman, or
      # (converted) Apptainer on a cluster: `nix build .#container`, then
      # `docker load < result` (or `podman load < result`), and
      # `docker run -it --rm -v "$PWD":/work NAME`. No Dockerfile: it is built
      # from flake.lock, so it holds exactly the versions you work with.
      packages = forEachSystem (pkgs: {
        container = pkgs.dockerTools.buildLayeredImage {
          inherit name;
          tag = "latest";
          contents = (environment pkgs false).packages ++ [
            pkgs.bashInteractive
            pkgs.coreutils
            pkgs.dockerTools.caCertificates # HTTPS from inside the container
          ];
          config = {
            Cmd = [ "bash" ];
            WorkingDir = "/work";
          };
        };
      });

      formatter = forEachSystem (pkgs: pkgs.nixfmt);
    };
}

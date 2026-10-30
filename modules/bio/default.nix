# Bioinformatics: what the system needs so per-project environments just
# work, and a few tools for quick looks at data. Pipelines, Python, R and
# their packages live in each project (`dvt bio`, from _templates/bio), so
# their versions stay pinned per project instead of drifting with the
# system. Apptainer is opt-in: extras/containers.nix.
{
  flake.templates.bio = {
    path = ./_templates/bio;
    description = "Bioinformatics: Python, R/Bioconductor, Snakemake, samtools and friends";
  };

  # Prebuilt Linux binaries (pip wheels, conda packages, vendor tools)
  # expect a standard dynamic loader and libraries; nix-ld provides them, so
  # these run instead of failing with "not found"
  flake.modules.nixos.bio = {
    programs.nix-ld.enable = true;
  };

  flake.modules.homeManager.bio =
    { pkgs, ... }:
    let
      # nixpkgs' micromamba is a script around a binary named .mamba-wrapped,
      # and the binary refuses to write its shell hook (`activate`) unless
      # its own file is named mamba or micromamba. Install it under its name;
      # it finds its libraries by absolute path, so the copy just works.
      micromamba = pkgs.runCommand "micromamba-${pkgs.mamba-cpp.version}" {
        meta.mainProgram = "micromamba";
      } "install -Dm755 ${pkgs.mamba-cpp}/bin/.mamba-wrapped $out/bin/micromamba";
    in
    {
      home.packages = with pkgs; [
        # conda environments (bioconda, conda-forge), for tools nixpkgs lacks
        # and protocols that ship an environment.yml:
        #   micromamba create -n qc -f environment.yml; micromamba activate qc
        micromamba
        seqkit # FASTA/FASTQ: stats, grep, sample, convert
        samtools # SAM/BAM/CRAM
        htslib # bgzip, tabix
      ];

      # Environments under ~/.local/share/mamba, not ~/micromamba
      home.sessionVariables.MAMBA_ROOT_PREFIX = "$HOME/.local/share/mamba";
      # `micromamba activate` needs its shell hook; loaded on first use, so
      # opening a terminal stays instant
      programs.bash.initExtra = ''
        micromamba() {
          unset -f micromamba
          eval "$(command micromamba shell hook --shell bash)"
          micromamba "$@"
        }
      '';
    };
}

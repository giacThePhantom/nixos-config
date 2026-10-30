# The manual (docs/), README, AGENTS.md and the agent skills are checked
# with every system build: a broken link or a missing heading fails it
# (_check-docs.sh). Part of base, so every machine runs it.
{
  flake.modules.nixos.base =
    { lib, pkgs, ... }:
    let
      src = lib.fileset.toSource {
        root = ../.;
        fileset = ../.;
      };
    in
    {
      system.checks = [
        (pkgs.runCommand "docs-links" { nativeBuildInputs = [ pkgs.gawk ]; } ''
          cd ${src}
          bash -euo pipefail ${./_check-docs.sh} README.md AGENTS.md docs/*.md .claude/skills/*/SKILL.md
          touch $out
        '')
      ];
    };
}

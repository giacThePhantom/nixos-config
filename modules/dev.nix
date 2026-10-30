# Development: per-project dev environments and coding tools.
#
# Each project carries its own flake.nix with a dev shell: `dvt NAME`
# (scripts/dvt.sh) in a project directory, or `nix flake init -t
# ~/.config/nixos#NAME`. The templates are the-nix-way/dev-templates plus our
# own (`bio`, in bio/). direnv + nix-direnv load the shell on `cd` and keep it
# cached, so no toolchain is installed globally. For a tool needed once,
# `, NAME` runs it without installing (comma).
{ inputs, ... }:
{
  flake.templates = inputs.dev-templates.templates;

  # NixOS's own "command not found" helper needs channels, which a flake
  # system has not; nix-index (below) replaces it
  flake.modules.nixos.dev = {
    programs.command-not-found.enable = false;
  };

  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      # A prebuilt index of every nixpkgs file, refreshed with `nix flake
      # update`: `, seqkit stats reads.fq` runs seqkit once, and an unknown
      # command suggests the package that has it
      imports = [ inputs.nix-index-database.homeModules.nix-index ];
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;

      home.packages = [
        pkgs.claude-code
        # Panes and sessions that show which agent is working or waiting (Super+Control+Return)
        inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true; # cached `use flake`, safe from garbage collection
        config.global.hide_env_diff = true; # just "direnv: loading", not every variable
      };

      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true; # git over https uses gh's login
        settings = {
          git_protocol = "ssh";
          prompt = "enabled";
          aliases = {
            co = "pr checkout";
            pv = "pr view";
          };
        };
      };
    };
}

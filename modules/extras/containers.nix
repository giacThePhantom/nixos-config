# Opt-in: containers. Podman runs Docker images rootless and without a
# daemon (the `docker` command works too, for scripts that call it);
# Apptainer (Singularity) runs and builds the images HPC clusters use
# (BioContainers, nf-core), unprivileged. A project's own image comes from
# its flake (`nix build .#container`, docs/10-projects.md). Opt-in because
# together they add ~510 MiB, half of it the Go compiler Apptainer keeps to
# compile extensions while building images. Enable it in hosts/.
{
  flake.modules.nixos.containers =
    { pkgs, ... }:
    {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true; # `docker` runs podman
        defaultNetwork.settings.dns_enabled = true; # containers find each other by name
      };
      programs.singularity = {
        enable = true;
        package = pkgs.apptainer;
      };
    };
}

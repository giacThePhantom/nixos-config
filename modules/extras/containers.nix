# Opt-in: containers. Podman runs Docker images rootless and without a
# daemon (the `docker` command works too, for scripts that call it);
# Compose files run with `docker compose` / `podman compose`, through
# podman's API socket, started on demand. Apptainer (Singularity) runs and
# builds the images HPC clusters use (BioContainers, nf-core), unprivileged.
# A project's own image comes from its flake (`nix build .#container`,
# docs/10-projects.md). Opt-in because together they add ~580 MiB, almost half
# it the Go compiler Apptainer keeps to compile extensions while building
# images. Enable it in hosts/.
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

      # Compose: `podman compose` hands the file to docker-compose, which
      # talks to the Docker API. Podman serves that API as your user (not
      # root, unlike dockerSocket.enable) on a socket systemd opens on demand;
      # DOCKER_HOST points docker-compose and other Docker API clients there.
      environment.systemPackages = [ pkgs.docker-compose ];
      systemd.user.sockets.podman.wantedBy = [ "sockets.target" ];
      environment.variables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
    };
}

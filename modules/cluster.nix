# University and cluster life: SSH that asks for the password (or 2FA) once,
# remote directories as local ones, cloud storage, backups, VPN.
{
  flake.modules.nixos.cluster =
    { pkgs, ... }:
    {
      # University VPNs (Cisco AnyConnect, GlobalProtect, Pulse/Ivanti) in
      # NetworkManager: `nmtui`, or Super+D > Setup > Network
      networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];
    };

  flake.modules.homeManager.cluster =
    { pkgs, ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        # Your own hosts go in ~/.ssh/config.d/ (yours to edit), e.g.
        #   Host hpc
        #     HostName login.hpc.example.edu
        #     User yourname
        includes = [ "config.d/*" ];
        settings."*" = {
          # Log in once per host; ssh, scp, rsync and sshfs then reuse that
          # connection, and keep it 10 minutes after the last one closes
          ControlMaster = "auto";
          ControlPath = "~/.ssh/cm-%C";
          ControlPersist = "10m";
          # Keep idle sessions from being dropped by firewalls
          ServerAliveInterval = 60;
          ServerAliveCountMax = 3;
        };
      };

      home.packages = with pkgs; [
        sshfs # `sshfs hpc:/scratch/me ~/hpc`: a cluster directory as a local one
        rclone # OneDrive/SharePoint, Google Drive, S3...: `rclone config`, then copy/sync/mount
        restic # encrypted, deduplicated backups, to a disk or any rclone remote
      ];
    };
}

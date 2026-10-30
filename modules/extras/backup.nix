# Opt-in: nightly encrypted backups with restic (history: 7 days, 5 weeks,
# 12 months). Before enabling it in hosts/, create two files only you can
# read (nothing secret goes in the Nix store):
#   ~/.config/restic/repository   where: /mnt/disk/backup, sftp:hpc:backup,
#                                 or rclone:REMOTE:backup (`rclone config`)
#   ~/.config/restic/password     the backup's password; lose it, lose the backup
# Then `systemctl --user start restic-backups-home` runs one now, and
# `restic -r "$(cat ~/.config/restic/repository)" snapshots` lists them.
{
  flake.modules.homeManager.backup =
    { config, ... }:
    let
      home = config.home.homeDirectory;
    in
    {
      services.restic = {
        enable = true;
        backups.home = {
          initialize = true; # create the repository on the first run
          repositoryFile = "${home}/.config/restic/repository";
          passwordFile = "${home}/.config/restic/password";
          # What is yours and irreplaceable, among these, whichever exist (a
          # missing one would fail the backup); data you can download again
          # (FASTQ, references) is better left out to keep backups small
          dynamicFilesFrom = ''
            for dir in ${home}/Documents ${home}/Projects ${home}/.config/nixos ${home}/.ssh; do
              if [ -e "$dir" ]; then echo "$dir"; fi
            done
          '';
          exclude = [
            ".direnv"
            ".snakemake"
            "__pycache__"
            "*.fastq.gz"
            "*.fq.gz"
            "*.bam"
            "*.cram"
          ];
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
          ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true; # missed while off: run at the next start
          };
        };
      };
    };
}

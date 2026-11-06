# Working with data at the command line: big tables, compression,
# benchmarks, and a queue for long jobs.
{ config, ... }:
let
  inherit (config) settings;
in
{
  # pueue's daemon is a systemd user service; lingering keeps the user's
  # services running without a login, so queued jobs survive logging out
  flake.modules.nixos.data = {
    users.users.${settings.user.name}.linger = true;

    # A job that needs more memory than there is (a STAR index wants ~32 GB)
    # should die, not drag the desktop through minutes of swapping. Compressed
    # swap in RAM (zram, used before the disk swap) absorbs short peaks;
    # earlyoom kills the biggest process once memory and most swap are gone,
    # with a notification. Not systemd-oomd: it kills a whole cgroup, and the
    # whole desktop (river and everything it starts) is one cgroup.
    zramSwap.enable = true;
    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5; # % of RAM still free...
      freeSwapThreshold = 75; # ...and % of swap: about zram's worth used
      enableNotifications = true;
      extraArgs = [
        "--avoid"
        "^(river|Xwayland)$" # the session itself
      ];
    };
  };

  flake.modules.homeManager.data =
    { pkgs, ... }:
    let
      # nixpkgs' visidata carries every optional loader (Parquet via Arrow,
      # S3, Postgres, maps, Reddit...): ~970 MiB. Its core reads TSV, CSV,
      # JSON and compressed files; keep Excel and YAML on top. Parquet and
      # S3 are duckdb's job.
      visidata = (pkgs.visidata.override { withPcap = false; }).overridePythonAttrs (old: {
        dependencies = with pkgs.python3Packages; [
          python-dateutil
          importlib-metadata
          standard-mailcap
          wcwidth
          zstandard
          openpyxl # .xlsx
          xlrd # .xls
          pyyaml
        ];
        doCheck = false; # the test suite exercises the dropped loaders
        pythonImportsCheck = [ "visidata" ];
      });
    in
    {
      home.packages = with pkgs; [
        visidata # `vd table.tsv`: a spreadsheet in the terminal, fast on millions of rows
        duckdb # SQL on CSV/TSV/Parquet files: duckdb -c "select … from 'counts.tsv'"
        parallel # one command per file, on every core: `parallel samtools index ::: *.bam`
        pv # progress of a long pipe: `pv big.fq.gz | zcat | …`
        pigz # gzip on every core
        zstd
        hyperfine # benchmark commands against each other
        dua # what fills the disk: `dua i` to browse folders by size and delete
        aria2 # fast, resumable downloads of big files: `aria2c -x 8 URL`
      ];

      # `pueue add -- snakemake --cores 8`: a queue for long jobs, which keep
      # running after the terminal closes; `pueue status`, `pueue log`
      services.pueue = {
        enable = true;
        # A desktop notification when each job ends
        settings.daemon.callback = "${pkgs.libnotify}/bin/notify-send -a pueue 'pueue job {{ id }}: {{ result }}' '{{ command }}'";
      };
    };
}

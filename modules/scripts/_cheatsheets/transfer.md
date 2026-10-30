# Moving data

    ssh hpc                                    # host from ~/.ssh/config.d/
    rsync -avP data/ hpc:/scratch/me/data/     # copy, resumable, only what changed
    rsync -avP --dry-run src/ dst/             # see what would happen first
    rsync -avP hpc:/scratch/me/results/ results/   # back
    scp file hpc:/scratch/me/                  # one file
    sshfs hpc:/scratch/me ~/hpc && fusermount -u ~/hpc   # mount, unmount
    rclone copy results/ onedrive:project/results -P     # cloud (rclone config first)
    aria2c -x 8 -c URL                         # big downloads: 8 connections, resume
    md5sum files > MD5SUMS && md5sum -c MD5SUMS   # check nothing got corrupted
    tar -czf archive.tar.gz folder/ && tar -xzf archive.tar.gz
    du -sh * | sort -h  /  dua i               # what takes space

Trailing slashes matter in rsync: `src/` copies the contents, `src` the folder itself.

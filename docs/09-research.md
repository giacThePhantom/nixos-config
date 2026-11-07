# Research tools

These are installed for everyone. Languages, pipelines and their packages
(Python, R, Snakemake, aligners...) are not: each project gets its own, see
[Projects](10-projects.md).

## Looking at data

| You want to | Type |
| --- | --- |
| Check a FASTQ or FASTA | `seqkit stats reads.fq.gz` (also `seqkit head`, `grep`, `sample`...) |
| Look into a BAM, CRAM or SAM | `samtools view -h sample.bam \| less`, `samtools flagstat sample.bam` |
| Compress and index for genome browsers | `bgzip calls.vcf`, `tabix -p vcf calls.vcf.gz` |
| Peek at variants | `bcftools view -H calls.vcf.gz \| less`, `bcftools stats calls.vcf.gz` |
| Overlap intervals | `bedtools intersect -a peaks.bed -b genes.bed -wa -u` |
| Explore a big table | `vd counts.tsv` (visidata: a spreadsheet in the terminal; also .csv, .xlsx, .json) |
| Query tables with SQL | `duckdb -c "select gene, sum(n) from 'counts.tsv' group by gene"` |
| Compress fast | `pigz` (gzip on every core), `zstd` |
| Run one command per file, on every core | `parallel samtools index ::: *.bam` |
| See how far a long pipe has got | `pv reads.fq.gz \| zcat \| wc -l` |
| Find what fills your disk | `dua i`: folders by size; `d` marks, `Ctrl + R` deletes |
| Download big files fast, resumably | `aria2c -x 8 URL` (eight connections; rerun to resume) |
| Download from SRA | in a project: `dvt bio download` gives `prefetch` and `fasterq-dump` |
| Calculate with units | `qalc "2 mL * 250 mmol/L to mmol"`, `qalc "50 ng/uL * 20 uL to ug"` |
| Compare tools for your methods section | `hyperfine 'tool-a input' 'tool-b input'` |

visidata in one minute: arrow keys move, `[` / `]` sort by the column,
`|` selects rows matching a pattern and `"` opens just those, `F` counts the
values in a column, `q` goes back.

## Long jobs

A pipeline that runs for hours shouldn't die when you close the terminal:

```sh
pueue add -- snakemake --cores 8    # queue it; it runs in the background
pueue status                        # what's running, waiting, done
pueue log                           # its output
pueue follow                        # watch it live
```

Jobs keep running after you log out, and you get the results when you're
back. Each finished job shows a notification, done or failed.

For a command in the terminal you're watching, `alert` does the same:
`alert snakemake --cores 8` tells you when it ends and how long it took.

If a job needs more memory than the computer has, it is stopped (with a
notification) once memory and most of the swap are used up, before the
desktop grinds to a halt. Run it on the cluster instead, or with fewer
threads: many tools use more memory per thread.

On the cluster, `hpc-wait hpc 123456 123457` waits for those SLURM jobs to
leave the queue and then notifies you of each one's result (completed,
failed, out of time or memory). It checks once a minute and copes with the
connection dropping; queue it so it survives closing the terminal:
`pueue add -- hpc-wait hpc 123456`.

## The cluster

**Log in once.** Write your cluster in `~/.ssh/config.d/hpc` (create the
folder; the name `hpc` is yours to choose):

```
Host hpc
  HostName login.hpc.example.edu
  User your-username
```

Now `ssh hpc` logs you in. Type your password (or 2FA code) once: for the next
10 minutes `ssh hpc`, `scp`, `rsync` and new terminals reuse that connection
without asking again.

**Cluster folders as local ones.**

```sh
mkdir -p ~/hpc && sshfs hpc:/scratch/your-username ~/hpc   # browse, open, copy
fusermount -u ~/hpc                                        # when done
```

**University VPN (GlobalProtect with single sign-on).** `Super + Shift + V`,
or `vpn` in a terminal, connects to the portal in `settings.nix`
(`vpnPortal`): a window opens on the university's login page (with its MFA
step), then `sudo` asks for your password to open the tunnel. It stays
connected while that terminal runs; `Ctrl + C` there, or `vpn off`
elsewhere, disconnects. It sends the host report (HIP) some portals ask for.

**Other university VPNs.** AnyConnect, GlobalProtect and Pulse VPNs without
single sign-on go through NetworkManager. Create yours once (address and type from your university's
IT pages; `protocol` is `anyconnect`, `gp` or `pulse`), then connect:

```sh
nmcli connection add type vpn vpn-type openconnect con-name uni \
  vpn.data "gateway=vpn.example.edu,protocol=anyconnect"
nmcli connection up uni --ask      # asks for your login
nmcli connection down uni
```

eduroam works as normal Wi-Fi.

**Cloud storage.** `rclone config` connects OneDrive, Google Drive, Dropbox or
S3 once; then `rclone copy`, `rclone sync`, or `rclone mount` it as a folder.

## Backups

Your thesis lives in one place until it doesn't. Turn on the optional
`backup` feature for automatic, encrypted backups every night, with history
(the last 7 days, 5 weeks and 12 months), of `~/Documents`, `~/Projects`,
this configuration and your SSH keys. Raw sequencing
files (`.fastq.gz`, `.bam`) are left out: you can download them again, and
they would fill any backup.

1. Decide where backups go, and write it in `~/.config/restic/repository`:
   a disk (`/mnt/backup/restic`), the cluster (`sftp:hpc:backup`), or cloud
   storage set up with rclone (`rclone:onedrive:backup`).
2. Choose a password and write it in `~/.config/restic/password`. Keep a copy
   somewhere safe: without it, the backups can't be read.
3. `chmod 600 ~/.config/restic/*`, add `backup` to the second list in
   `modules/hosts/nixos/default.nix`, and `rebuild`.

Run one now with `systemctl --user start restic-backups-home`. To see your
backups and get files back:

```sh
export RESTIC_REPOSITORY_FILE=~/.config/restic/repository RESTIC_PASSWORD_FILE=~/.config/restic/password
restic snapshots                              # the list
restic restore latest --target ~/restored     # everything, into ~/restored
```

To keep folders identical between your laptop and your workstation instead,
there's the optional `syncthing`.

## References

[papis](https://papis.readthedocs.io) keeps your library as plain files: a
folder per paper in `~/Documents/papers`, with the PDF and its details. You
can sync it, back it up, or put it in git.

```sh
papis add --from doi 10.1093/bioinformatics/btp352   # by DOI
papis add --from arxiv 2106.15928                    # from arXiv
papis add paper.pdf                                  # a PDF you have
papis open samtools                                  # find it, open the PDF
papis edit samtools                                  # fix its details
papis export --all --format bibtex > refs.bib        # for your thesis
```

Citation keys look like `li2009`. LaTeX, Typst and Quarto cite from
`refs.bib`. papis has no Microsoft Word plugin: if you write in a word
processor with live citations, Zotero is the tool (it isn't installed: its
current build relies on an outdated, insecure browser engine).

## Reading papers

PDFs open in zathura: fast, with pages in the desktop's colours.

For papers, the optional `sioyek` (see [Applications](08-applications.md#optional-apps))
is worth its 300 MiB. It becomes the default for PDFs, and:

- middle-click a reference like "Fig. 3", "Eq. 2" or "[14]" to jump there, even in
  PDFs without links; `Backspace` brings you back;
- a *portal* (`p`) keeps a figure on screen in a second window while you read the
  text about it;
- highlights and bookmarks are searchable across every PDF you've read;
- a ruler (right-click a line) keeps your place in dense text;
- a table of contents (`t`) even for PDFs that don't have one.

`:` searches its commands; `F8` switches between the desktop's colours and the
original ones.

## Notes

[zk](https://zk-org.github.io/zk/) keeps notes as plain Markdown files in
`~/Documents/notes`, linked with `[[wiki links]]`, which you can sync, back
up or put in git. The launcher's *Notes* menu has the same commands.

```sh
zk journal               # today's lab notebook entry: what you did, results, next
zk paper li2009          # notes on a paper, by its papis citation key
zk new --title "Read trimming"   # any other note
zk edit -i               # find a note by title or content
zk recent                # the last two weeks
zk list --link-to papers/li2009.md   # notes that link to a paper
```

`zk paper` fills in the title, authors, journal and DOI from your papis
library, so add the paper there first (see [References](#references)); run
it again later to reopen the same notes.

Notes open in Neovim, which knows your notebook:

| Keys | What |
| --- | --- |
| `[[` | start a link: suggests your notes as you type |
| `gd` or `Ctrl + ]` | follow the link under the cursor (`Ctrl + O` to come back) |
| `K` | preview the note a link points to |
| `gr` | the notes that link to this one |

A link to a note that doesn't exist is underlined.

## PDF forms and signing

- A form with fields to fill (the PDF has real boxes you can click): open it
  in Firefox, fill it in, and save with `Ctrl + S`.
- A scan, or a PDF you need to write on: Xournal++ (in the launcher). Open the
  PDF, type or draw on it, add your signature as an image (keep a scan of it
  in `~/Documents`), then *File → Export as PDF*.

## Writing

- Write your thesis or papers per project: `dvt latex`, `dvt typst` (see
  [Projects](10-projects.md)).
- `pandoc` converts between Markdown, LaTeX, Word and HTML:
  `pandoc notes.md -o notes.docx`.
- PDFs: `pdfunite a.pdf b.pdf out.pdf` (merge), `pdfseparate` (split),
  `pdftotext` (extract text), `pdfinfo`.
- Word documents look right: the fonts Word uses (Calibri, Cambria, Arial,
  Times New Roman) are replaced by free fonts with exactly the same letter
  widths, so lines and pages break in the same places.

## The graphics card

`nvtop` shows what's using it. CUDA builds of packages (PyTorch, JAX...) in
your projects are downloaded ready-made instead of being compiled for hours.

Next: [Projects](10-projects.md).

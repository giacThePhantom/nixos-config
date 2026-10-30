# Data

Raw data lives in `data/raw/`, is never edited, and is not in git (it is too
big, and may be sensitive). This file records where every file came from, so
anyone can get the same data.

| File(s) | Source (accession, URL) | Retrieved | Notes |
| --- | --- | --- | --- |
| `raw/SRR0000000_1.fastq.gz` | SRA SRR0000000 | 2026-01-31 | example row |

Checksums, so you know the data is the one described here:

```sh
cd data/raw && md5sum * > ../MD5SUMS      # once, after downloading
cd data/raw && md5sum -c ../MD5SUMS       # any time later
```

Human data (genomes, health records) is personal data under the GDPR: keep it
only on storage your institution approves for it, never in personal cloud
storage or in git, and follow the project's data management plan.

# samtools: SAM/BAM/CRAM alignments

## Look
    samtools view -h in.bam | less -S          # with header; -S: no line wrap
    samtools view in.bam chr1:10000-20000      # a region (needs an index)
    samtools flagstat in.bam                   # mapped, paired, duplicates...
    samtools idxstats in.bam                   # reads per chromosome (indexed)
    samtools stats in.bam | grep ^SN           # summary numbers

## Convert, sort, index
    samtools sort -@ 8 -o out.bam in.sam       # sort by coordinate (and SAM -> BAM)
    samtools sort -n -o byname.bam in.bam      # sort by read name
    samtools index out.bam                     # .bai, needed for regions
    samtools view -C -T ref.fa -o out.cram in.bam   # BAM -> CRAM (needs the reference)

## Filter (-f keep flags, -F drop flags, -q min MAPQ)
    samtools view -b -F 4 in.bam > mapped.bam            # drop unmapped
    samtools view -b -q 30 -F 0x904 in.bam > uniq.bam    # MAPQ >= 30, primary only
    samtools view -c -f 2 in.bam                         # count properly paired

## Duplicates (sorted by name, fixmate, sorted by position, markdup)
    samtools sort -n in.bam | samtools fixmate -m - - | samtools sort - | samtools markdup - md.bam

## Back to reads
    samtools fastq -1 r1.fq.gz -2 r2.fq.gz -0 /dev/null -s /dev/null -n in.bam

## Depth
    samtools depth -a in.bam > depth.tsv       # per position, including zeros
    samtools coverage in.bam                   # per chromosome summary

Flags: `cheat formats`. Faster: add `-@ THREADS` to most commands.

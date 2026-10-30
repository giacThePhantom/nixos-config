# bedtools: genomic intervals

BED is 0-based, half-open: `chr1 0 100` is the first 100 bases (`cheat formats`).
Most commands want sorted input: `sort -k1,1 -k2,2n in.bed > sorted.bed`.

## Overlaps
    bedtools intersect -a a.bed -b b.bed            # the overlapping parts
    bedtools intersect -a a.bed -b b.bed -u         # a's intervals that overlap b (once)
    bedtools intersect -a a.bed -b b.bed -v         # a's intervals that do not
    bedtools intersect -a a.bed -b b.bed -wa -wb    # both records, side by side
    bedtools intersect -a peaks.bed -b genes.bed -f 0.5   # at least 50% of a

## Combine, subtract, complement
    bedtools merge -i sorted.bed -d 100             # merge within 100 bp
    bedtools subtract -a a.bed -b b.bed
    bedtools complement -i sorted.bed -g genome.txt  # the gaps (genome.txt: chrom<TAB>size)

## Nearby
    bedtools closest -a a.bed -b genes.bed -d       # nearest, with distance
    bedtools window -a a.bed -b b.bed -w 1000       # within 1 kb
    bedtools slop -i a.bed -g genome.txt -b 500     # extend 500 bp both sides
    bedtools flank -i genes.bed -g genome.txt -l 2000 -r 0 -s   # promoters (strand-aware)

## Counting and coverage
    bedtools coverage -a regions.bed -b reads.bam   # reads and covered fraction per region
    bedtools genomecov -ibam in.bam -bg > cov.bedgraph

## Sequences
    bedtools getfasta -fi ref.fa -bed regions.bed -s -name > regions.fa

genome.txt from a FASTA index: `samtools faidx ref.fa && cut -f1,2 ref.fa.fai > genome.txt`.

# File formats and their coordinates

## Coordinates: the classic off-by-one
| Format | First base | Ends | `chr1:1-100` written as |
| --- | --- | --- | --- |
| BED, BAM (internally), bigWig | 0 | exclusive | `chr1 0 100` |
| SAM, VCF, GFF/GTF, samtools/IGV regions | 1 | inclusive | `chr1 1 100` |

BED start = 1-based start - 1; BED end = 1-based end.

## FASTQ: four lines per read
    @read_id description
    SEQUENCE
    +
    QUALITIES            # Phred+33: char - 33 = Q; Q20 = 1% error, Q30 = 0.1%

## SAM columns
QNAME FLAG RNAME POS(1-based) MAPQ CIGAR RNEXT PNEXT TLEN SEQ QUAL [TAGS]

## SAM FLAG bits (add them up; explain one: `samtools flags 99`)
| Bit | Dec | Meaning |
| --- | --- | --- |
| 0x1 | 1 | paired |
| 0x2 | 2 | properly paired |
| 0x4 | 4 | unmapped |
| 0x8 | 8 | mate unmapped |
| 0x10 | 16 | reverse strand |
| 0x20 | 32 | mate reverse strand |
| 0x40 | 64 | first in pair (R1) |
| 0x80 | 128 | second in pair (R2) |
| 0x100 | 256 | secondary |
| 0x200 | 512 | failed QC |
| 0x400 | 1024 | duplicate |
| 0x800 | 2048 | supplementary |

Primary, mapped only: `-F 0x904` (4 + 256 + 2048).

## CIGAR
M match/mismatch, I insertion, D deletion, N skipped (introns, RNA-seq),
S soft clip (bases kept in SEQ), H hard clip, = match, X mismatch.

## VCF
CHROM POS(1-based) ID REF ALT QUAL FILTER INFO FORMAT sample...
Genotypes: `0/0` hom ref, `0/1` het, `1/1` hom alt, `./.` missing, `|` phased.

## GTF/GFF
seqname source feature start end score strand frame attributes (1-based, inclusive).

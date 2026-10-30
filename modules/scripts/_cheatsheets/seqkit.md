# seqkit: FASTA/FASTQ

    seqkit stats -a *.fq.gz                    # reads, lengths, N50, Q20/Q30 (-a: all)
    seqkit head -n 4 in.fq.gz                  # first records
    seqkit seq -m 50 in.fq.gz -o long.fq.gz    # keep reads >= 50 bp
    seqkit sample -p 0.1 -s 11 in.fq.gz -o sub.fq.gz   # 10%, seed 11 (reproducible)
    seqkit sample -n 100000 -s 11 -2 in.fq.gz  # 100k reads (-2: two-pass, low memory)
    seqkit grep -p seq_id ref.fa               # a record by ID
    seqkit grep -f ids.txt ref.fa              # records listed in a file
    seqkit grep -s -p GATTACA in.fa            # by sequence (-s), -m 1: 1 mismatch
    seqkit grep -p chr1 ref.fa | seqkit subseq -r 100:200   # a region (1-based, inclusive)
    seqkit fq2fa in.fq.gz -o out.fa
    seqkit rmdup -s in.fa -o dedup.fa          # remove duplicate sequences
    seqkit split2 -p 4 in.fq.gz -O parts/      # split into 4 files
    seqkit pair -1 r1.fq.gz -2 r2.fq.gz        # re-pair mates after filtering
    seqkit fx2tab -n -l -g in.fa               # name, length, GC per record

Any command: `-j THREADS`. Pipes work: `seqkit seq -m 50 in.fq.gz | seqkit stats`.

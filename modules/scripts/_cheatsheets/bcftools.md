# bcftools: VCF/BCF variants

## Look
    bcftools view -h in.vcf.gz | tail -1        # the column header (samples)
    bcftools view -H in.vcf.gz | less -S        # records, no header
    bcftools stats in.vcf.gz > stats.txt        # counts, Ts/Tv... (plot-vcfstats)
    bcftools query -l in.vcf.gz                 # sample names

## Compress and index (most commands need it)
    bgzip in.vcf && tabix -p vcf in.vcf.gz      # or: bcftools index in.vcf.gz

## Select
    bcftools view -r chr1:1000-2000 in.vcf.gz           # region (indexed)
    bcftools view -s S1,S2 in.vcf.gz                    # samples
    bcftools view -v snps -m2 -M2 in.vcf.gz             # biallelic SNPs only
    bcftools view -i 'QUAL>30 && INFO/DP>10' in.vcf.gz  # by expression
    bcftools view -e 'GT="mis"' in.vcf.gz               # drop missing genotypes

## Extract to a table
    bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL[\t%GT]\n' in.vcf.gz

## Call variants
    bcftools mpileup -f ref.fa a.bam b.bam | bcftools call -mv -Oz -o calls.vcf.gz

## Combine and tidy
    bcftools merge a.vcf.gz b.vcf.gz -Oz -o merged.vcf.gz   # different samples
    bcftools concat chr1.vcf.gz chr2.vcf.gz -Oz -o all.vcf.gz  # same samples
    bcftools norm -f ref.fa -m -any in.vcf.gz -Oz -o norm.vcf.gz # left-align, split multiallelics
    bcftools annotate --rename-chrs map.txt in.vcf.gz      # chr1 <-> 1

Output: `-Oz` compressed VCF, `-Ob` BCF, `-Ov` plain. VCF positions are 1-based (`cheat formats`).

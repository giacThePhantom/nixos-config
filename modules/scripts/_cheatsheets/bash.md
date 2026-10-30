# bash: the shell

## History
    !!  /  sudo !!       the previous command / again, with sudo
    !$  /  !*            the previous command's last argument / all its arguments
    ^fq^fa               the previous command, with fq replaced by fa
    !samtools            the latest command starting with samtools
    Ctrl+R               search history (fzf);  ↑ / ↓: commands starting with what's typed
    fc                   edit the previous command in Neovim, then run it

## Folders and file names
    cd -                 back to the previous folder (pushd DIR / popd: a stack of them)
    z name               jump to a folder you've visited (zoxide)
    **/*.bam             BAM files in every subfolder
    !(*.gz)              everything except .gz files
    *.@(fq|fastq).gz     either ending
    {data,results,logs}  mkdir -p {data,results,logs}; cp file{,.bak}; echo s{01..12}

## Parts of a variable (f=data/sample01_R1.fq.gz)
    ${f##*/}             sample01_R1.fq.gz   (cut the longest */ from the start)
    ${f%/*}              data                (cut the shortest /* from the end)
    ${f%_R1.fq.gz}       data/sample01
    ${f/R1/R2}           data/sample01_R2.fq.gz
    ${var:-default}      a fallback when var is empty or unset
    $(cmd)               the output of cmd, as text

## Loops
    for r1 in data/*_R1.fq.gz; do
      s=${r1##*/}; s=${s%_R1.fq.gz}
      fastp -i "$r1" -I "${r1/_R1/_R2}" -o "trim/${s}_R1.fq.gz" -O "trim/${s}_R2.fq.gz"
    done
    while read -r id; do echo "$id"; done < ids.txt      # one line at a time

## Outputs as files, and inputs as text
    diff <(samtools view -H a.bam) <(samtools view -H b.bam)
    comm -12 <(sort a.txt) <(sort b.txt)     # lines in both
    grep -c chr <<< "$text"                  # a string as input
    cmd > out.txt 2> err.txt                 # output and errors apart (&> both)

## Jobs
    cmd &                run in the background;  Ctrl+Z then bg: the same, after starting
    jobs  /  fg %1       list them / bring one back
    pueue add -- cmd     long jobs: survive closing the terminal

## Scripts
    set -euo pipefail    stop at the first error, unset variable, failed pipe
    echo $?              the last exit code (0 = success); ${PIPESTATUS[@]}: each in a pipe
    type ll  /  help cd  what a name is (alias, function, program) / help on a builtin

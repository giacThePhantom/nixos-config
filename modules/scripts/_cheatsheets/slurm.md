# SLURM: cluster jobs

    sbatch job.sh                      # submit; prints the job ID
    squeue --me                        # your jobs (older SLURM: squeue -u $USER)
    scancel JOBID                      # cancel (scancel --me: all of yours)
    sacct -j JOBID --format JobID,State,Elapsed,MaxRSS,ExitCode   # after it ends
    seff JOBID                         # efficiency: did it use what it asked for
    sinfo                              # partitions and free nodes
    srun --cpus-per-task 4 --mem 8G --time 1:00:00 --pty bash   # interactive shell on a node
    scontrol show job JOBID            # everything about a job
    hpc-wait hpc JOBID                 # (here) a notification when it finishes

## job.sh
    #!/bin/bash
    #SBATCH --job-name=align
    #SBATCH --cpus-per-task=8
    #SBATCH --mem=32G
    #SBATCH --time=12:00:00
    #SBATCH --output=logs/%x-%j.out     # %x name, %j job ID
    #SBATCH --array=1-24                # 24 tasks: $SLURM_ARRAY_TASK_ID is 1..24
    set -euo pipefail
    sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" config/samples.txt)
    minimap2 -t "$SLURM_CPUS_PER_TASK" -ax sr ref.fa "data/raw/$sample.fq.gz" \
        > "results/$sample.sam"

Ask for what you need (check `seff` of a past job): oversized requests wait longer in the queue.

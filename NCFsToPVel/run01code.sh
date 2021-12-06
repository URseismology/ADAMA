#!/bin/bash

## loop through the pair-list files (~100 pirs per file)
do
  ## read in the txt file that have the list of station pairs to slurm
  sbatch --export=i=$i run01code.slurm
  numJobs=`/software/slurm/current/bin/squeue -p urseismo -u sxue3 | wc -l`
  ((numJobs=numJobs-1))
  if (( numJobs >= 100 ))
  then
    sleep 5m
  fi
done

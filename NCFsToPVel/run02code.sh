#!/bin/bash

## loop through all existing text CCF outputs and do 02 code for all pairs

# F changes below
for i in /scratch/tolugboj_lab/Prj5_HarnomicRFTraces/AkiEstimate/tutorial/InitialPhase/InitialPhase_02/*.love
do
  file=$(basename "$i")
  filename=$(echo $file | cut -d'.' -f 1)
  sta1=$(echo $filename | cut -d'_' -f 2)
  sta2=$(echo $filename | cut -d'_' -f 3)
  pair="${sta1}_${sta2}"
  out02="../ResultOf02/ResultOf02_02/Initial_${pair}/opt.pred-love"  ## F changes here
  echo $pair
  ## skip the pair if the pair has already been processed
  if [ ! -s $out02 ]
  then
    sbatch --export=pair=$pair run02code.slurm
    ## check if the jobs on the node are too many
    numJobs=`/software/slurm/current/bin/squeue -p debug -u sxue3 | wc -l`
    ((numJobs=numJobs-1))
    if (( numJobs >= 150 ))
    then
      sleep 2m
    fi
  fi
done

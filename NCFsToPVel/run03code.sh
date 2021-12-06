#!/bin/bash

## loop through all existing text CCF outputs and do 03 code for all pairs

## F changes here
for i in /scratch/tolugboj_lab/Prj5_HarnomicRFTraces/AkiEstimate/tutorial/ResultOf02/ResultOf02_02/*
do
  file=$(basename "$i")
  sta1=$(echo $file | cut -d'_' -f 2)
  sta2=$(echo $file | cut -d'_' -f 3)
  pair="${sta1}_${sta2}"
  out03="../ResultOf03/ResultOf03_02/Final_${pair}/opt.pred-love"  ## F changes here
  echo $pair
  ## skip the pair if the pair has already been processed
  if [ ! -s $out03 ]
  then
    sbatch --export=pair=$pair run03code.slurm
    ## check if the job on debug is less than 70
    numJobs=`/software/slurm/current/bin/squeue -p urseismo -u sxue3| wc -l`
    ((numJobs=numJobs-1))
    if (( numJobs >= 150 ))
    then
      sleep 2m
    fi
  fi
done

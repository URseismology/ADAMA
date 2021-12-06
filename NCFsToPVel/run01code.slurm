#!/bin/bash

#SBATCH -J Aki01
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p urseismo
#SBATCH -t 1:00:00

module load gcc/9.1.0 python/2.7.12 fftw3/3.3.7/b1 gsl/2.5/b1

pairs="./Aki01_lists/${i}.txt"
cat $pairs | while read line 
do
  ##file=$(basename "$line")
  ##filename=$(echo $line | cut -d'.' -f 1)
  sta1=$(echo $line | cut -d'_' -f 1)
  sta2=$(echo $line | cut -d'_' -f 2)
  pair="${sta1}_${sta2}"
  
  out01="../InitialPhase/InitialPhase_02/phase_${pair}.love"  ## F changes here
  echo $pair
  ## skip the pair if the pair has already been processed
  if [ ! -f $out01 ]
  then
    ../01_create_initial_target_phase.sh $pair
  fi
done

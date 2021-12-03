#!/bin/bash
## bash script for parallizing data pre-prossing of each station

#SBATCH -J seisDwnLD 
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p urseismo
#SBATCH -t 120:00:00

module load anaconda3/2019.10
source activate urseismo
cd /scratch/tolugboj_lab/Prj5_HarnomicRFTraces/para_prepross/
date
echo "Job started!"
mkdir -p "./command_output/${net}"
command_out="./command_output/${net}/${net}-${sta}-out.txt"
 > $command_out
python3 ./pre_pross.py $netdir $outroot $net $sta $dayfile >> $command_out


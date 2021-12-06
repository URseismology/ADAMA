#!/bin/bash
 
#SBATCH -J get_BH_CCF 
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p urseismo
#SBATCH -t 7-00:00:00

module load matlab/r2019a
matlab -nodisplay -nodesktop -nosplash -r "get_BH_CCF($nSubmit);exit"

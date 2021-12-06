#!/bin/bash

#SBATCH -J Aki02
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p debug
#SBATCH -t 0:10:00

module load gcc/9.1.0 python/2.7.12 fftw3/3.3.7/b1 gsl/2.5/b1

../02_fit_initial_target_phase.sh $pair

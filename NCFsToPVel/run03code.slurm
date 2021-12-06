#!/bin/bash

#SBATCH -J Aki03
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -p urseismo
#SBATCH -t 00:20:00

module load gcc/9.1.0 python/2.7.12 fftw3/3.3.7/b1 gsl/2.5/b1

../03_fit_bessel.sh $pair

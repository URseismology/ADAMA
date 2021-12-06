#!/bin/bash
## bash script for the crontab to submit CCF jobs
## Nov. 18, 2021 -- Siyu Xue

## To add this to cron jobs
## crontab -e
##      */5 * * * * /home/bliu17/Programming/Scripts/for_urseismo/auto_submit/autoSubmit.sh

numJobs=`/software/slurm/current/bin/squeue -p urseismo | wc -l`
((numJobs=numJobs-1))

cd /scratch/tolugboj_lab/Prj5_HarnomicRFTraces/Extra_from_noise/CCF_auto
read nSubmit < submit.txt

if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

module load circ slurm

if (( nSubmit >= 145 ))
then
exit;
fi

if (( numJobs <= 50 ))
then
  echo $nSubmit
  ##((nSubmit++))
  sbatch --export=nSubmit=$nSubmit get_BH_CCF.slurm
fi


## GVib to NCFs
Scripts to download raw data as SEED files from IRIS using the rover system, downsample, remove instrument response,  rotate, and postprocess the SEED to SAC files and automate using SLURM bash scripts on the High-performance computing (HPC) platform bluehive. Finally MATLAB scripts to compute NCFS using the Russell codes generalized for HPC on bluehive.

1. Download Data Code
Implemented using the batch rover system, available at https://github.com/URseismology/LithoAFR-SWave/tree/main/parDatDwnld 
2. Pre-processing Code 
- generate_diff.py: generate a pickle file (containing the missing dates) for each station if its data are not all pre-processed. 
- pre_pross.py: downsample, remove instrument, and save as SAC files. 
- pre_pross.sh & pre_pross.slurm: parallel computing tools
3. DLOPy Code
- runOrientOfflinepp.py: run the DLOPy orientation code offline (need the catalog downloaded)
- readlocalAFpp.py: python functions for reading the local SEED files. 
- orientation.csv: orientation for all stations if available.
- ppdata_dic.data: pickle file stored all pre-processed station names with an array of dates indicating when do we have the data of. 
4. Noise CCF Code
- autoSubmitCCF.sh & get_BH_CCF.slurm: set cron job to compile get_BH_CCF.m
- get_BH_CCF.m: sends a fixed number of parallel Noise CCF jobs to the server. 
- a1_ccf_ambnoise_RTZ_NE_Para.m: does Noise CCF for stations with [N E Z] channels, then save the CCF results in mat and text (later for AkiEstimate) formats.
- a1_ccf_ambnoise_RTZ_12_Para.m: does Noise CCF for stations with [1 2 Z] channels, then save the CCF results in mat and text (later for AkiEstimate) formats.

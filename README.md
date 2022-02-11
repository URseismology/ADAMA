# Data, Code, and Measurement files for ADAMA

A Short-Period Surface Wave Dispersion Dataset for Model Assessment of Africa’s Crust: ADAMA.D1
 Tolulope Olugboji, and Siyu Xue


Please cite as: Xue, S and Olugboji, T. (2021). URseismology/ADAMA: ADAMA.2 (v0.2). Zenodo. https://doi.org/10.5281/zenodo.5753071


---
## Directory Overview

### 1.Data Files (CSV and HDF5):
- ADAMA_stalist:  Station metadata 
- ADAMA_gvib: Displacement seismograms at 1 Hz 
- ADAMA_staconns: List of station pairs that are connected - 150K 
- ADAMA_ncfs: NCFs for connected station pairs 
- ADAMA_raw: Phase & group velocity extracted from NCFs (Raw) 
- ADAMA_clean: Same as (5) but downsampled (11 periods) and cleaned 
### 2.Data Readers and Writers (MATLAB & Python): 
buildADAMAncf.m – compiles the dataset from ncf results
read_ADAMA_ncfs.m – read in the ncf of a station pair as HDF5 files
buildADAMAraw.py – compiles the dataset from raw AkiEstimate files
read_ADAMA_raw.m – read in the Aki phase velocity as HDF5 files
buildADAMAclean.m – convert dispersion results to ASCII files
### 3.Plotting Scripts (MATLAB) 
All scripts for making plots for manuscript, are provided as: 
fig1_heatmaps.m
fig2_AfrAllStaQlty.m
fig3_AkiEst.m
fig4_orientationTest.m
fig5_CCFintime.m
fig6_pathavgModel.m
fig7_Aki03PVresults.m
fig7_getAkiData.m
fig8_comparePVResults.m
fig9_AFRTomoMap.m
fig9_GDM52Map.m
fig9_LithoMap.m
fig10_outlierRayPath.m
figS3_ConnDuraSNR.m
plotplates.m
saveFig.m
Outlier_analysis.m
### 4.GVib to NCFs (Python, Bash, SLURM, MATLAB)
Scripts to download raw data as SEED files from IRIS using the rover system, downsample, remove instrument response,  rotate, and postprocess the SEED to SAC files and automate using SLURM bash scripts on the High-performance computing (HPC) platform bluehive. Finally MATLAB scripts to compute NCFS using the Russell codes generalized for HPC on bluehive.
### 5.NCFs to Phase Velocity (SLURM Bash) 
Scripts that use NCFs from 4 above, converted to ASCII files, and produce phase velocities - C_o. Again, SLURM bash scripts that run the whole process using the HPC system.
run01code.sh & run01code.slurm: run Aki01 code in parallel. 
run02code.sh & run02code.slurm: run Aki02 code in parallel. 
run03code.sh & run03code.slurm: run Aki03 code in parallel.


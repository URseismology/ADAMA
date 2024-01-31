import obspy
from obspy import read
import glob

#### Input in terminal
# module load anaconda/2018.12
# source activate urseismo

#    Save all pre-processed results into a huge HDF5 file

namefile = 'ADAMA_gvib.h5'

for path in glob.glob('/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/preprocessed_data/Data*/*/*.sac'):
    try:
        stream = read(path)
        stream.write(namefile, 'H5', mode='a')
    except:
        print(path)


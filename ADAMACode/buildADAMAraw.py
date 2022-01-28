###### Convert all Aki Results (in text format) to HDF5 files
#### Tolulope Olugboji & Siyu Xue
#### Dec. 28, 2021

from obspy import read
from obspy.clients.fdsn import Client

from obspy import Trace, Stream
import obspyh5
import scipy.io
import glob
import numpy as np
#from obspy.geodetics import gps2dist_azimuth
from geopy.distance import geodesic
import os
from IPython.display import clear_output
from tqdm import tqdm
import pandas as pd
from matplotlib import pyplot as plt 


def aki2hdf(n1, s1, n2, s2, loc1, loc2, chan, xdata, fvals):
    sr = 1
    #loc in lat lon
    #gps_args = (loc1[0], loc1[1], loc2[0], loc2[1])
    #dist = gps2dist_azimuth(*gps_args)[0] / 1000 / 111.2
    coords_1 = (loc1[0], loc1[1])
    coords_2 = (loc2[0], loc2[1])
    dist = geodesic(coords_1, coords_2).km
    
    fo =fvals[0]
    fn = fvals[1]
    nf = fvals[2]
        
    #xdata = correlate(tr1.data, tr2.data, int(round(maxshift * sr)))
    header = {'network': n1, 'station': s1, 'location': n2, 'channel': s2,
              'network1': n1, 'station1': s1, 'location1': loc1, 'channel1': chan,
              'network2': n2, 'station2': s2, 'location2': loc2, 'channel2': chan,
              'sampling_rate': sr, 'fo': fo, 'fend': fn, 'N': nf,  'distance': dist}
    
    return Trace(data=xdata, header=header)

## 1.cf_love, 2.cf_ral, 3.co_love, 4.co_ral, 5. u_love, 6. u_ral, 7., env_love, 8.env_ral, 9.bes_love, 10.bes_ral 
# On Terra
# inDir_co = '/RAID6/bluehiveBackup/Prj5_HarnomicRFTraces/2_Data/ResultOf02_02'
# inDir_cf = '/RAID6/bluehiveBackup/Prj5_HarnomicRFTraces/2_Data/ResultOf03_02'
# path_sta = '/RAID6/bluehiveBackup/Prj5_HarnomicRFTraces/2_Data/ADAMA_stalist.csv'

# On BlueHive
inDir_co = '/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/ResultOf02_02'
inDir_cf = '/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/ResultOf03_02'
path_sta = '/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/ADAMA_stalist.csv'


wavetyps = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2] # love -ral love-ral ...
usemethd = [1, 1, 2, 2, 1, 1, 1, 1, 1, 1 ] # aki3, aki3, aki1, aki1, ...
usecols = [2, 2, 2, 2, 1, 1, 4, 4, 3, 3 ] # phase, group, env, bessel
outlbls = ['cf', 'cf', 'co', 'co', 'u', 'u', 'env', 'env', 'bes', 'bes']

#msg = 'start'
#client = Client("IRIS")
cntBad = 0;

obspyh5.set_index('xcorr')
    
for ifile in range(10):
    runWave = wavetyps[ifile]
    runMethod = usemethd[ifile]
    colindx = usecols[ifile]
    lbl = outlbls[ifile]
    #print([ifile, runWave, runMethod, colindx])
    #print(lbl)
    
    if runMethod == 1:
        inDirBase = inDir_cf
    else:
        inDirBase = inDir_co
        
    if runWave == 1:
        inFile = inDirBase+'/*/opt.pred-love'
        outName = 'ADAMAraw_'  + lbl + '_love.h5'
        chan = 'TT'
    else:
        inFile = inDirBase+'/*/opt.pred-rayleigh'
        outName = 'ADAMAraw_'  + lbl + '_ral.h5'
        chan = 'ZZ'
        
    print(inFile)
    print(outName)

    pbar = tqdm(glob.glob(inFile))
    
    for path in pbar:
        msg = ''

        fname = os.path.basename(os.path.dirname(path))
        fsplit = fname.split('_')
        #print(fsplit)

        netsta1 = fsplit[1]
        netsta2 = fsplit[2]

        net1 = netsta1.split('-')[0]
        sta1 = netsta1.split('-')[1]

        net2 = netsta2.split('-')[0]
        sta2 = netsta2.split('-')[1]

        try:
            #### read coordinates from csv file: loc1 & loc2
            sta_list = pd.read_csv(path_sta)
            row1 = sta_list.loc[(sta_list['Network'] == net1) & (sta_list['Station'] == sta1)]
            row2 = sta_list.loc[(sta_list['Network'] == net2) & (sta_list['Station'] == sta2)]

            loc1 = [round(float(row1['Latitude']), 3), round(float(row1['Longitude']), 3)]
            loc2 = [round(float(row2['Latitude']), 3), round(float(row2['Longitude']), 3)]


            #### read coordinates from online inventory (no need if reading from the station csv file)
            #inv1 = client.get_stations(network=net1, sta=sta1, loc="*", channel="*")
            #inv2 = client.get_stations(network=net2, sta=sta2, loc="*", channel="*")

            #sobj = inv1[0][0]
            #loc1 = [sobj.latitude, sobj.longitude]

            #sobj = inv2[0][0]
            #loc2 = [sobj.latitude, sobj.longitude]

            
            msg = msg + net1 + '.'  + sta1 +  '-' + net2 + '.' + sta2 + ' Bad: ' + str(cntBad)
            pbar.set_description(msg)
            dat = np.loadtxt(path)

            savedat = dat[:, colindx]
            freq = dat[:, 0]
            fvals = [freq[0], freq[-1], len(freq)]

            # read table as pandas object? -- scan meta and get distance
            # ---
            trace = aki2hdf(net1, sta1, net2, sta2, loc1, loc2, chan, savedat, fvals)
            trace.write(outName, 'H5', mode='a')
            pbar.set_description(msg)

        except:
            cntBad = cntBad + 1
            print("Read error. Caught!")
            clear_output(wait=True)


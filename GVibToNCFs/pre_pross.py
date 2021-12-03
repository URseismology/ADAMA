import obspy
from obspy.clients.fdsn import Client
from obspy import UTCDateTime
from obspy.core import AttribDict
from obspy.io.sac import SACTrace
import numpy as np
import os
import pandas as pd

from obspy import read
from obspy import read_inventory

import glob
import configparser
import multiprocessing
import time
import sys
import pickle

def one_station_process(netstadir, output_root_path, network, station, days_file):
    # load the days that need pre-processing 
    with open(days_file, 'rb') as filehandle:
        days = pickle.load(filehandle)

    print(f"{netstadir}: job starts")

    # Note: all responses were downloaded to the inventory directory: ./inventory/net/net-sta.xml
    # webservice = "IRIS"  
    # client = Client(webservice)
    # inv = client.get_stations(network=network, station=station, level="response")

    inv = read_inventory(f"./inventory/{network}/{network}-{station}.xml", format="STATIONXML")
    is_removeresp = 1
    is_downsamp = 1
    sr_new = 1
    nfiles = 0
    yrs = os.listdir(netstadir)

    # create a csv file to record the all failed days during the pre-processing
    fail_writer = open(f'./fail_process/{network}/{network}-{station}.csv', 'w')
    
    ifile = 0
    ifail = 0
    nfiles = len(days)
    for d in days:
        if "DS_Dtore" in d: # avoid any DS_Store file created by the MAC system
            continue

        yr, day = d.split(".")
        dayfiledir = netstadir + yr + '/' + day + '/'
        files = os.listdir(dayfiledir)
            
        for file in files:
            if file[-3:] == "tmp": # skip all temp files
                continue
                
            print(f"Working on {network}-{station}: {yr}.{day}")
            filepath = netstadir + yr + '/' + day + '/' + file
            raw_st = read(filepath)
            
            try: 
                # select traces we need: BH?, LH?, HH?
                st = raw_st.select(channel="BH*") + raw_st.select(channel="HH*") + raw_st.select(channel="LH*") 
                # NOTE: before merge, a channel could have multiple traces due to the broken records. 
                st.merge(method=1, fill_value=0) # fill all datagaps with 0
            except Exception: # merge function does not do well with LOG files. If that's the case, need to remove LOG file first
                ifail += 1
                print("Failed to merge the stream")
                fail_writer.write(f'{yr},{day}, merge\n')
                continue
                        
            # generate a list of all avaliable channels of the station
            chan_list = []
            sampr_list = []
            for tr in st:
                chan_list.append(tr.stats.channel)
                sampr_list.append(tr.stats.sampling_rate)
            
            print("all channels of this station:", chan_list)
            print("   sample rates of the channels:", sampr_list)
            
            try:
                # select the set of channels with the smallest sampling rate (when greater than 1.0)
                tchan = np.array(chan_list)
                tsamp = np.array(sampr_list)
                values, counts = np.unique(tsamp, return_counts = True)
                for i in range(len(values)):
                    if counts[i] == 3 and values[i] >= 1:
                        small_samp_rate = values[i]
                        break
                new_chan_list = tchan[np.where(tsamp == small_samp_rate)]
                if not new_chan_list.size:
                    print("*** Not enough data, skipping this day ***")
                    ifail += 1
                    continue
    
                print("   channels we will be using:", new_chan_list)
                new_st = st.copy()
                new_st.clear()
                for i in new_chan_list:
                    new_st += st.select(channel=i)
                st = new_st
            except Exception:
                print("*** Not enough data, skipping this day ***")
                ifail += 1
                fail_writer.write(f'{yr},{day},missing data\n')
                continue
                
            tr = st[0]
            tstart = tr.stats.starttime
            tend = tr.stats.endtime

            tdbeg = UTCDateTime(tstart)
            tdend = UTCDateTime(tend)

            comp = tr.stats.channel
            network = tr.stats.network
            station = tr.stats.station

            sr = tr.stats.sampling_rate
                      
            # tr.plot()
            # print('yr ' + str(yr) + ' of ' + str(yrs))
  
            print('removing ' + str(ifile+ifail) + ' of ' + str(nfiles)) 
            print('  tot fail: ' + str(ifail) + 'of' + str(nfiles))
            print('  tot pass: ' + str(ifile)+ 'of' + str(nfiles))
            
            if is_removeresp:
                try:
                    st.attach_response(inv)
                    st.remove_response(output="DISP", zero_mean=True, taper=True, taper_fraction=0.05,
                                       pre_filt=[0.001, 0.005, sr / 3, sr / 2], water_level=60)
                    
                    # trim pad, downsample and save
                    st.merge(method=1, fill_value=0) # fill all datagaps with 0
                    st.trim(starttime=tdbeg, endtime=tdend, pad=True, nearest_sample=False,
                            fill_value=0)  # make sure correct length
                    st.detrend(type='demean')
                    st.detrend(type='linear')
                    st.taper(type="cosine", max_percentage=0.05)

                    if is_downsamp and sr != sr_new:
                        st.filter('lowpass', freq=0.4 * sr_new, zerophase=True)  # anti-alias filter
                        st.filter('highpass', freq=1 / 60 / 60, zerophase=True)  # Remove daily oscillations
                        st.decimate(factor=int(sr / sr_new), no_filter=True)  # downsample
                        st.detrend(type='demean')
                        st.detrend(type='linear')
                        st.taper(type="cosine", max_percentage=0.05)

                    # convert to SAC and fill out station/event header info
                    for tr in st:
                        sac = SACTrace.from_obspy_trace(tr)
                        sac.stel = inv[0].stations[0].elevation
                        sac.stla = inv[0].stations[0].latitude
                        sac.stlo = inv[0].stations[0].longitude
                        kcmpnm = sac.kcmpnm
                        yr = str(tr.stats.starttime.year)
                        jday = '%03i' % (tr.stats.starttime.julday)
                        hr = '%02i' % (tr.stats.starttime.hour)
                        mn = '%02i' % (tr.stats.starttime.minute)
                        sec = '%02i' % (tr.stats.starttime.second)
                        sac_out = f'{output_root_path}/Data{network}/{station}/{station}.' + \
                                  f'{yr}.{jday}.{hr}.{mn}.{sec}.{kcmpnm}.sac'
                        
                        if not os.path.exists(f'{output_root_path}/Data{network}/{station}'):
                            os.makedirs(f'{output_root_path}/Data{network}/{station}')
                        sac.write(sac_out)
                    
                    ifile += 1
                    print('removed response for above & saved to file!')
                except Exception as e:
                    daystr = tdbeg.strftime('%Y-%m-%dT%H:%M:%S.%fZ')
                    ifail += 1
                    print('Failed to remove response: ' + daystr )
                    print(e)
                    fail_writer.write(f'{yr},{day}, removeresp\n')
                    continue

    fail_writer.close()
# The order of input: netstadir, output_root_path, network, station, days

netstadir = sys.argv[1]
output_root_path = sys.argv[2]
network = sys.argv[3]
station = sys.argv[4]
days_file = sys.argv[5]

one_station_process(netstadir, output_root_path, network, station, days_file)

import glob
import numpy as np
import pandas as pd
import os
import sys

# Enter the path to downloaded data, pre-processed data, and directory where you want to store diff data
input_root_path = sys.argv[1]  #/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/para_preposs_test/data_download
output_root_path = sys.argv[2] #/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/para_preposs_test/data_processed
diff_day_path = sys.argv[3]  #/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/para_preposs_test/diff_day

def one_station_summary(netstadir, network, station):
    nfiles = 0  # count the total numbel of date files
    yrs_raw = np.array(os.listdir(netstadir))
    yrs = yrs_raw
    for i in yrs_raw:
        if "DS_Store" in i:
            yrs = np.delete(yrs, np.where(yrs == i))
    try:         
        yrs = np.delete(yrs, np.where(["._.DS_Store", ".DS_Store"]))
    except Exception:
        pass
    yrs = np.sort(yrs)
    
    nyrs = len(yrs)
    daycnt = np.zeros(nyrs) # initialize a list of years with dimension nyrs
    
    daylist = np.empty(nyrs, dtype=object) # initializing a list of list daylist[i] --> [ 001, 110, 360]

    
    for iyr in range(nyrs):
        yr = yrs[iyr]

        dayfiledir = netstadir+yr
        days = np.array(os.listdir(dayfiledir))
        
        daylist[iyr] = days
        
        ndays =len(days)
        daycnt[iyr] = ndays
        nfiles = nfiles+ndays
        
    return yrs, daylist, nfiles

# Create a dictionary contains all downloaded data
data_dic = {}

for path in glob.glob(f"{input_root_path}/*/*/datarepo/data/*/"):
    value_pointer = 0
    network = path.split("/")[-2]
    station = path.split("/")[-5].split("-")[-1]
    key = (network +'-'+station)  # station as the key in dictionary
    yrs,daylist,nfiles = one_station_summary(path, network, station)

    # sort the date
    for i in range(len(daylist)):
        daylist[i] = np.sort(daylist[i])
        
    # now generate the values (date file) for each key
    values = np.empty(nfiles, dtype=object)        
    for i in range(len(yrs)):   # loop through the year
        for j in daylist[i]:
            values[value_pointer] = (yrs[i]+'.'+j)
            value_pointer += 1

    data_dic[key] = values

# Create a pre-processed data dictionary based on the generated SAC files if data_processed is not empty
if len(os.listdir(output_root_path)) == 0:
    diff_dic = data_dic
else:
    ppdata_dic = {}

    # SAC file path: output_root_path/Datanetwork/station/station.year.day.hr.mn.sec.kcmpnm.sac
    for path in glob.glob(f"{output_root_path}/*/*/"):
        value_pointer = 0
        sta = path.split("/")[-2]
        net = (path.split("/")[-3])[4:]
        key = net + '-' + sta
    
        values = np.empty(len(glob.glob(f"{output_root_path}/Data{net}/{sta}/*")), dtype=object)
    
        for sac in glob.glob(f"{output_root_path}/Data{net}/{sta}/*"):
            filename = sac.split("/")[-1]
            year = filename.split(".")[1]
            day = filename.split(".")[2]
            values[value_pointer] = (year+"."+day)
            value_pointer += 1

        values = np.sort(np.unique(values))
        ppdata_dic[key] = values

    # Compare the download dictionary and the pre-proccessed dictionary
    #### NOTE: ASSUME that all data are pre-processed in order based on the date (2018.001 is processed before 2018.002)

    diff_dic = {}  # dictionary to record the difference between two dictionaries
    for sta in data_dic:
        if sta in ppdata_dic and len(ppdata_dic[sta]) > 1:
            last_day_pross = ppdata_dic[sta][-1]  # get the last day that was pre-possessing 
        
            diff_days = np.setdiff1d(data_dic[sta], ppdata_dic[sta])  # get the difference
            diff_days = np.append(diff_days, last_day_pross)  # the last day in ppdata_dic is also included in diff_dic
            diff_dic[sta] = diff_days  
        else:
            diff_dic[sta] = data_dic[sta]  # if the station has not been processed, copy data_dic to diff_dic

# Write the values of each key in diff_dic to a pickle file for future pre-processing
import pickle
for k in diff_dic:
    values = diff_dic[k]
    net, sta = k.split("-")
    filename = diff_day_path +'/'+ net +'-'+ sta +".data"
    with open(filename, 'wb') as filehandle:
    # store the data as binary data stream
        pickle.dump(values, filehandle)

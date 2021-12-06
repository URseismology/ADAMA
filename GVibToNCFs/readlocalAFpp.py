# Modified to read local SEED files
# Modified by Siyu Xue -- Nov. 30, 2021

import obspy
from obspy import read
from obspy.core import UTCDateTime
from numpy import *
from scipy import signal

#t1 = UTCDateTime(2014, 9, 7, 12, 15)
#t2 = 4*60*60     # Length of data to download
#sta = 'NR-NE201'
#dir1 ='/RAID6/tarBackUp2/'
#dir1 ='/scratch/tolugboj_lab/Prj10_DeepLrningEq/9_DanielSequencer/3_src/obspy_batch/'

def getmsd2(t1,t2,dir1,sta):
    t1=UTCDateTime(t1)
    netNm = sta.split('-')[0]
    staNm = sta.split('-')[1]
    year = t1.year
    julday = t1.julday
    no_data = False
    # need to change to path to downloaded data for day t1
    f1 = f'{dir1}{netNm}/{sta}/datarepo/data/{netNm}/{year}/{julday}/{staNm}.{netNm}.{year}.{julday}'
    
    try:
        d = read(f1)  # read in the file
    except Exception:
        print("Failed to read the file1")
        no_data = True
        
    # include next day of data if close to edge
    if t1.hour >= 20:
        end_time = t1 + t2
        year = end_time.year
        julday = end_time.julday
        # need to change to path to downloaded data for (day t1 + 1)
        f2 = f'{dir1}{netNm}/{sta}/datarepo/data/{netNm}/{year}/{julday}/{staNm}.{netNm}.{year}.{julday}'
        try:
            d2 = read(f2)  # read in the file
            d3 = d+d2
            d = d3.merge()
        except Exception:
            print("Failed to read or merge the file2")
            no_data = True
            
    if no_data:
        return "getmsd2 failed"
    else:
        chan_list = []
        # select channels
        for tr in d:
            chan_list.append(tr.stats.channel)

        if "LHZ" in chan_list:
            st1 = d.select(channel="LH*")        
        elif "BHZ" in chan_list:
            st1 = d.select(channel="BH*")
        elif "HHZ" in chan_list:
            st1 = d.select(channel="HH*")
        else:
            no_data = True
        # set sampling rate
        sps=20
        
        if no_data:
            return "getmsd2 failed"
        else:
            return st1.slice(starttime=t1,endtime=(t1+t2))
	# end of the function

def getppdata(ts,td,dir1,sta):
    ts=UTCDateTime(ts)
    netNm = sta.split('-')[0]
    staNm = sta.split('-')[1]
    year = ts.year
    julday = ts.julday
    comp12 = False
    
    # need to change to path to downloaded data for day t1
    fz = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?HZ.sac'
    try:
        tz = read(fz)  # read in the file
    except Exception as e:
        print("Failed to read the file1Z")
        print(e)
        return "getppdata failed"
        
    try:
        fe = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?HE.sac'
        fn = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?HN.sac'
        tn = read(fn)
        te = read(fe)
    except Exception as e:
        f1 = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?H1.sac'
        f2 = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?H2.sac'
        t1 = read(f1)
        t2 = read(f2)
        comp12 = True
    
    if ts.hour >= 20:
        end_time = ts + td
        year = end_time.year
        julday = end_time.julday
        # need to change to path to downloaded data for (day t1 + 1)
        fz2 = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?HZ.sac'
        try:
            tz2 = read(fz2)  # read in the file
        except Exception:
            print("Failed to read file2Z")
            return "getppdata failed"

        try:
            fe2 = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?HE.sac'
            fn2 = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?HN.sac'
            tn2 = read(fn2)
            te2 = read(fe2)
        except Exception:
            f12 = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?H1.sac'
            f22 = f'{dir1}Data{netNm}/{staNm}/{staNm}.{year}.{julday}.??.??.??.?H2.sac'
            t12 = read(f12)
            t22 = read(f22)
        
        try:
            if not comp12:
                tz3 = tz + tz2
                te3 = te + te2
                tn3 = tn + tn2
                tz = tz3.merge()
                tn = tn3.merge()
                te = te3.merge()
                s = tz3 + te3 + tn3              
            else:
                tz3 = tz + tz2
                t13 = t1 + t12
                t23 = t2 + t22
                tz = tz3.merge()
                t1 = t13.merge()
                t2 = t23.merge()
                s = tz3 + t13 + t23
        except Exception as e:
            print(e)
            return "getppdata failed"
        
    else:
        if not comp12:
            s = tz + te + tn
        else:
            s = tz + t1 + t2

    return s.slice(starttime=ts,endtime=(ts+td))
    #end of function

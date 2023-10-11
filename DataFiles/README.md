## Data Files
#### 1. Master List for Stations:

All stations we are working with along with their coordinates are stored in the file ADAMA_stalist.csv. The 'In_africa' column indicates whether the station is on the African continent. The 'connCnt' column shows how many connections the station has in our connection file. The 'Orientation' column indicates how we received orientation measurement of the stations: 0 = none/ 1 = DLOPy/ 2 = Ojo's study. The 'CCF' column indicats whether the station participates in the CCF results we reported. 

#### 2. Master List for Station Pair Connections:

ADAMA_staconns.csv contains all possible station pair connections computed using all avaliable pre-processed data with a minimum distance of 60 km. This csv files contain network names, station names, coordinations, distance, and the number of 4-hour-overlap-window for the two stations in each pair. The 'result' column indicats who the station pair is utilized: 0 = not used to compute CCF/ 1 = used to compute CCF and not an outlier/ 2 = used to compute CCF and is an outlier

#### 3. Station Pair Connections with special constraints:

prepross_connection_1.csv: all connections in ADAMA_staconns.csv that have at least one station in the pair having comp as [1,2,Z]

#### 4. Access NCf(ADAMAncfs) and pe-processed(ADAMA_raw) data in hdf5 format:
https://repovibranium.earth.rochester.edu:5001/sharing/SgvBDpbli

#### 5. Original SEED files downloaded using ROVER(private):
Backup at RAID6/bluehive_bk_monthly/obspy_batch_bk_Oct062021/

#### 1. Master List for Stations:
All stations we are working with along with their coordinates are stored in the file ADAMA_stalist.csv. The 'In_africa' column indicates whether the station is on the African continent. The 'connCnt' column shows how many connections the station has in our connection file. The 'Orientation' column indicates how we received orientation measurement of the stations: 0 = none/ 1 = DLOPy/ 2 = Ojo's study. The CCF column indicats whether the station participates in the CCF results we reported. 

#### 2. The two csv prepross_connection files here are derived from the original pre-processed connection file:

(0): all connections in the original pp connection file with distance_km > 60

(1): all connections in (0) that have at least one station in the pair having comp as [1,2,Z]

#### 3. Access pe-processed data in hdf5 format:
https://repovibranium.earth.rochester.edu:5001/sharing/SgvBDpbli

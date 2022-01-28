function [freq, rncf, incf, msg] = Read_ADAMA_ncfs(NET_STA1, NET_STA2, CHAN)
%% Author: Baowei Liu, baowei.liu@rochester.edu
%% Goal: read out the noise correlation function (NCF) between two stations pairs
%%       from hdf5 created by python
%% Input: NET_STA1,2: the network.stations
%%        CHAN: channel Name (R, T, Z)
%% Output: frequency: array with frequency values
%%         rncf:      real part of NCF
%%         incf:      imaginary part of NCF
%%         msg:       message about the running 
%% Example of Usage: [freq, rncf, incf, msg] = Read_ADAMA_ncfs('ZV.SUMA', 'G.ATD', 'Z');
%% Updated: 12.9.2021 
%% Modified by Siyu: Dec. 29, 2021
%%   -- Deleted the LettersPattern section of the code
%%   -- Updated the channel search based on user input
%%   -- Added the station switch (now sta2_sta1 will also return true results)

clc


%% 
rfn = '/scratch/tolugboj_lab/DrO_Terra2BHive/1_ForSiyu/ADAMA_ncfs_ZZ_fr.h5';
ifn = '/scratch/tolugboj_lab/DrO_Terra2BHive/1_ForSiyu/ADAMA_ncfs_ZZ_fi.h5';

freq = zeros(7200,1);
rncf = zeros(7200,1);
incf = zeros(7200,1);

%% find the channel names from the filename
% (note: all channel files have the '.ZZ-.ZZ' channel, so no need to change it)
chn = strcat(CHAN,CHAN);
chnP = strcat('.ZZ-.ZZ');

% direct to the correct h5 file with given channel
rfn = strrep(rfn, 'ZZ', chn);
ifn = strrep(ifn, 'ZZ', chn);

grpNm = strcat('/waveforms/',NET_STA1,'-',NET_STA2, '/', chnP, '/');
%% hard-coded dataset name

msg = 'Finished searching...';
datasetNm = strcat(grpNm, '1970-01-01T00:00:00_1970-01-01T01:59:59');

try
  rncf = h5read(rfn, datasetNm);
catch
  try
      grpNm = strcat('/waveforms/',NET_STA2,'-',NET_STA1, '/', chnP, '/');
      datasetNm = strcat(grpNm, '1970-01-01T00:00:00_1970-01-01T01:59:59');
      rncf = h5read(rfn, datasetNm);
  catch
    msg = strcat('cannot find real NCF data for: ', NET_STA1, NET_STA2);
  end
end

try
  incf = h5read(ifn, datasetNm);
catch
  try
      grpNm = strcat('/waveforms/',NET_STA2,'-',NET_STA1, '/', chnP, '/');
      datasetNm = strcat(grpNm, '1970-01-01T00:00:00_1970-01-01T01:59:59');
      incf = h5read(ifn, datasetNm);
  catch
    msg = strcat(msg, '; cannot find imag NCF data for: ', NET_STA1, NET_STA2);
  end
end
  
T = 4*60*60*1; %% 4 hours at 1Hz sRate
dt = 1; %%1 second
freq = [1/T:1/T:0.5*dt]; 

end

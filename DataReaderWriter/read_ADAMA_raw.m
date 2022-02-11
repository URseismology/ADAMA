function [freq, pvel, msg] = read_ADAMA_raw(NET_STA1, NET_STA2, WTYPE, TARGET)
%% Author: Baowei Liu, baowei.liu@rochester.edu
%% Goal: read out the phase velocity results from AkiEstimate between two stations pairs
%%       from hdf5 created by python
%% Input: NET_STA1,2: the network.stations
%%        WTYPE: (wave type) L, R
%%        TARGET: co, cf, u, bes, env
%% Output: frequency: array with frequency values
%%         pvel:     target data
%%         msg:      message about the running 
%% Example of Usage: [freq, pvel, msg] = read_ADAMA_raw('3D.MM09', '1C.MM09', 'L', 'cf');
%% Updated: 12.9.2021 

%% Modified by Siyu: Jan. 1, 2022
%%   -- Deleted the LettersPattern section of the code
%%   -- Added the station switch (now sta2_sta1 will also return true results)
%%   -- No long need the channel as input

clc

%% Testing
% NET_STA2 = 'AF.KTWE';
% NET_STA1 = '2H.DALE';
% WTYPE = 'L';
% TARGET = 'co';

%% 
switch WTYPE
  case 'L' 
    fn = ['/Users/sxue3/Documents/Figures/data/ADAMAdata/ADAMAraw_', TARGET, '_love.h5'];
    CHAN = 'T';
  case 'R' 
    fn = ['/Users/sxue3/Documents/Figures/data/ADAMAdata/ADAMAraw_', TARGET, '_ral.h5'];
    CHAN = 'Z';
  otherwise
    msg = 'wrong wave type given';
    disp('please give correct wave type: ', 'L or ', 'R');
end


freq = zeros(7200,1);
pvel = zeros(7200,1);
msg ='';

%% Find the dataset name, switch station names if needed

grpSTA = strcat('/waveforms/',NET_STA1,'-',NET_STA2);

try
  grpInfo = h5info(fn, grpSTA);
  grpNm = grpInfo.Groups.Name;
  datasetNm = strcat(grpNm, '/1970-01-01T00:00:00_1970-01-01T01:59:59');
  pvel = h5read(fn, datasetNm);
catch
    try 
        grpSTA = strcat('/waveforms/',NET_STA2,'-',NET_STA1);
        grpInfo = h5info(fn, grpSTA);
        grpNm = grpInfo.Groups.Name;
        datasetNm = strcat(grpNm, '/1970-01-01T00:00:00_1970-01-01T01:59:59');
        pvel = h5read(fn, datasetNm);
    catch
        msg = strcat('cannot find data for: ', NET_STA1,'-', NET_STA2);
    end
end

T = 4*60*60*1; %% 4 hours at 1Hz sRate
dt = 1; %%1 second
freq =  [1/T:1/T:0.5*dt]; 

end

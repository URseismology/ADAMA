%%  Script to parallelize computing CCF
%   Authors: Siyu Xue -- June 14, 2021

function [] = get_BH_CCF(nSubmit)
%nSubmit = 0;
% connect to the cluster
d = parcluster('Bluehive_r2019a'); 
d.AdditionalProperties.AdditionalSubmitArgs='-t 21500 -p urseismo'; %-t in minutes
d.NumWorkers = 400; %set number of workers
ap = {'/scratch/tolugboj_lab/Prj2_SEUS_RF/3_Src'};

nStart = nSubmit * 200 + 1;  % 200 jobs will be submitted each time this function is triggered. 
nEnd = (nSubmit + 1) * 200;

% ---- read in the station pair list ------
PairList = '/gpfs/fs2/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/Extra_from_noise/CCF_auto/zpairs.csv';
A = readtable(PairList);
stanet1 = A{nStart:nEnd,'Var1'};
stalist1 = A{nStart:nEnd,'Var2'};
stanet2 = A{nStart:nEnd,'Var5'};
stalist2 = A{nStart:nEnd,'Var6'};
nsta = length(stanet1);
winlength = 4;

% ------ set some paths ------
parameters.workingdir = '/gpfs/fs2/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/Extra_from_noise/CCF_auto/';

parameters.ccfpath = [parameters.workingdir,'ccf/'];
parameters.figpath = [parameters.workingdir,'figs/'];
parameters.seis_path = [parameters.workingdir,'seismograms/'];
parameters.logpath = [parameters.workingdir,'ccf_log/'];

% ------ Build File Structure: cross-correlations -------
ccf_path = parameters.ccfpath;
ccf_winlength_path = [ccf_path,'window',num2str(winlength),'hr/'];
ccf_singlestack_path = [ccf_winlength_path,'single/'];
ccf_daystack_path = [ccf_winlength_path,'dayStack/'];
ccf_monthstack_path = [ccf_winlength_path,'monthStack/'];
ccf_fullstack_path = [ccf_winlength_path,'fullStack/'];

if ~exist(ccf_path)
    mkdir(ccf_path)
end
if ~exist(ccf_winlength_path)
    mkdir(ccf_winlength_path)
end
if ~exist(ccf_singlestack_path)
    mkdir(ccf_singlestack_path)
end
if ~exist(ccf_daystack_path)
    mkdir(ccf_daystack_path)
end
if ~exist(ccf_monthstack_path)
    mkdir(ccf_monthstack_path)
end
if ~exist(ccf_fullstack_path)
    mkdir(ccf_fullstack_path)
end
if ~exist(parameters.logpath)
    mkdir(parameters.logpath)
end

txtpathR = [parameters.workingdir,'text_output/RayleighResponse_R/'];
txtpathT = [parameters.workingdir,'text_output/LoveResponse/'];
txtpathZ = [parameters.workingdir,'text_output/RayleighResponse/'];
if ~exist(txtpathZ)
    mkdir(txtpathZ)
end
if ~exist(txtpathR)
    mkdir(txtpathR)
end
if ~exist(txtpathT)
    mkdir(txtpathT)
end

log_path = [parameters.workingdir,'ccf_log/'];
if ~exist(log_path)
    mkdir(log_path)
end

PATHS = {ccf_singlestack_path; ccf_daystack_path; ccf_monthstack_path; ccf_fullstack_path};
for ipath = 1:length(PATHS)
    ccfR_path = [PATHS{ipath},'ccfRR/'];
    ccfT_path = [PATHS{ipath},'ccfTT/'];
    ccfZ_path = [PATHS{ipath},'ccfZZ/'];
    if ~exist(ccfR_path)
        mkdir(ccfR_path);
    end
    if ~exist(ccfT_path)
        mkdir(ccfT_path);
    end
    if ~exist(ccfZ_path)
        mkdir(ccfZ_path);
    end
end

% Build File Structure: figures
figpath = parameters.figpath;
fig_winlength_path = [figpath,'window',num2str(winlength),'hr/'];
if ~exist(figpath)
    mkdir(figpath);
end
if ~exist(fig_winlength_path)
    mkdir(fig_winlength_path);
end

% Build File Structure: windowed seismograms
seis_path = parameters.seis_path;
seis_winlength_path = [seis_path,'window',num2str(winlength),'hr/'];
if ~exist(seis_path)
    mkdir(seis_path);
end
if ~exist(seis_winlength_path)
    mkdir(seis_winlength_path);
end

parameters.figpath = [parameters.workingdir,'figs/'];


% ------ parallel the job ------

for istai = 1:nsta % parallel each station pair
    allJobs = [];
    sta1=char(stalist1(istai,:));
    net1=char(stanet1(istai,:)); 
    sta2=char(stalist2(istai,:));
    net2=char(stanet2(istai,:)); 

    ccfT_fullstack_path = [ccf_fullstack_path,'ccfTT/'];
    if exist([ccfT_fullstack_path,net1,'-',sta1,'/',net1,'-',sta1,'_',net2,'-',sta2,'_f.mat'])
        display(['CCF file for the pair: ', net1, '-', sta1 ' and ', net2, '-',sta2, ' already exists, skipping...']);
        continue
    elseif exist([ccfT_fullstack_path,net2,'-',sta2,'/',net2,'-',sta2,'_',net1,'-',sta1,'_f.mat'])
        display(['CCF file for the pair: ', net1, '-', sta1 ' and ', net2, '-',sta2, ' already exists, skipping...']);
        continue
    end
    display(['Submiting job for the pair: ', net1, '-', sta1 ' and ', net2, '-',sta2, ' ...']);

    % Submit the Noise CCF job to the server
    % @a1_ccf_ambnoise_RTZ_NE_Para for stations with [N E Z]
    % @a1_ccf_ambnoise_RTZ_12_Para for stations with [1 2 Z]
    remoteJob = batch(d, @a1_ccf_ambnoise_RTZ_NE_Para, 0, {sta1, net1, sta2, net2, PATHS}, ...
    'AdditionalPaths', ap, ...
    'CaptureDiary', false, 'AutoAddClientPath', false, 'Pool', 2); % give each job 2 workers

    allJobs = [allJobs remoteJob];
       
end

% save the progress number to submit.txt
fid = fopen('./submit.txt','w');
nSubmit = nSubmit + 1;
fprintf(fid,'%d\n',nSubmit);
fclose(fid);

end % end the function

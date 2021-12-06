% Calculate ambient noise cross correlation record from multiple stationpairs 
% for (Z, R, T) using the methods from Bensen et al. (2007) GJI 
% DOI:10.1111/j.1365-246X.2007.03374.x
% !! Currently requires data to be downsampled to 1 Hz !!
%
% Expects files organized like so:
% {datadirectory}/{station}/{station}.{yyyy}.{jday}.{hh}.{mm}.{SS}.{COMP}.sac
%  e.g.: mydata/CC05/CC05.2018.112.00.00.00.BDH.sac
%
% JBR, Jan 2020: Implemented frequency-time normalization after 
% Shen et al. (2012) BSSA; DOI:10.1785/0120120023. This greatly improves signal
% extraction compared to typical one-bit noralization and whitening of Bensen et
% al. (2007) GJI. Faster FiltFiltM() can be replaced with MATLAB's slower 
% built-in filtfilt().
%
% (NOTE: FUNCTIONIZE IN THE FUTURE)
% Patty Lin -- 10/2014
% Natalie Accardo
% Josh Russell
% https://github.com/jbrussell

% Modified by Siyu for the automation purpose -- Nov 30, 2021
% Noise CCF results will be saved as mat file and text file in the AkiEstimate format

function [] = a1_ccf_ambnoise_RTZ_NE_Para(sta1, net1, sta2, net2, PATHS)

%%% Copied the setup_paramters
% Modified for automation 
addpath('/gpfs/fs2/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/Extra_from_noise/CCF_auto/functions/');
addpath('/gpfs/fs2/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/Extra_from_noise/CCF_auto/functions/calc_Rayleigh_disp/');

%%% --- Paths to important files --- %%%
workingdir = '/gpfs/fs2/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/Extra_from_noise/CCF_auto/';

datadir = ['/gpfs/fs2/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/preprocessed_data/']; % @Siyu: should be the file that contains all network data folders

log_path = [workingdir,'ccf_log/', net1,'-',sta1, '_', net2,'-',sta2, '.txt'];

log_file = fopen(log_path, 'w');
timenow = datestr(datetime('now'));
fprintf(log_file, timenow);
fprintf(log_file, '  Start the log\n');
tStart = tic;

%parameters.PZpath = '../INSTRUMENT/'; 
% don't need PZpath if download data using the python script
ccfpath = [workingdir,'ccf/'];
figpath = [workingdir,'figs/'];
seis_path = [workingdir,'seismograms/'];

%%% --- Parameters for using Radon Transform picks --- %%%
parameters.path_LRT_picks = './mat-LRTdisp/LRT_picks/';


% PZpath = parameters.PZpath;
% don't need PZpath if download data using the python script

orientation_path = '/gpfs/fs2/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/orientation.csv';

%%% End of setup paths

IsFigure1 = 0;
IsSaveTxt = 1; % Export the data into a text file

% OUTPUT SETTINGS
IsOutputFullstack = 1; % Save full year ccf stacks
IsOutputMonthstack = 0; % save month ccf stacks
IsOutputDaystack = 0; % save day ccf stacks
IsOutputSinglestack = 0; % save single ccf before stacking
IsOutputSeismograms = 0; % save raw seismograms before cross-correlating

%%% --- Parameters to build up gaussian filters --- %%%
min_width = 0.18;
max_width = 0.30;

%%% --- Parameters for initial processing --- %%%
dt = 1; % sample rate
dist_min = 40; % min. distance in kilometers

%%% --- Parameters for ccf_ambnoise --- %%%
winlength = 4; %hours
Nstart_sec = 50; % number of sections to offset start of seismogram

%%% --- Parameters for fitbessel --- %%%
npts = winlength*3600;

% GENERAL PROCESSING
IsRemoveIR = 0; % remove instrument response
IsDetrend = 1; % detrend the data
IsTaper = 1; % Apply cosine taper to data chunks

%%%%%%%%%%% OPTIONS FOR PREPROCESSING %%%%%%%%%%%%
% (1) ONE-BIT NORMALIZATION & SPECTRAL WHITENING? (Bensen et al. 2007)
IsSpecWhiten = 0; % Whiten spectrum
IsOBN = 0; % One-bit normalization

% (2) TIME-FREQUENCY NORMALIZATION (Ekstrom et al. 2009; Shen et al. 2011)
IsFTN = 1; % Frequency-time normalization? (If 1, applied instead of whitening and one-bit normalization)
% Changed 1/10 to 1/3
frange_FTN = [1/60 1/3]; % frequency range over which to construct FTN seismograms

% (3) BASIC PREFILTER (Ekstrom 2011)
IsPrefilter = 0; % apply butterworth bandpass filter before cross-correlation?
frange_prefilt = [1/100 1/10];

Nstart = Nstart_sec/dt; % Number of samples

% Build File Structure: cross-correlations
ccf_path = ccfpath;
ccf_winlength_path = [ccf_path,'window',num2str(winlength),'hr/'];
ccf_singlestack_path = [ccf_winlength_path,'single/'];
ccf_daystack_path = [ccf_winlength_path,'dayStack/'];
ccf_monthstack_path = [ccf_winlength_path,'monthStack/'];
ccf_fullstack_path = [ccf_winlength_path,'fullStack/'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off','MATLAB:nargchk:deprecated')
%% ------------------- loop through center station station-------------------

% READ ORIENTATIONS
A = readtable(orientation_path);
slist = A{:,'Var1'};
orientations = A{:,'Var2'};

% Calculate filter coefficients for FTN
if IsFTN
    [ b, a ] = get_filter_TFcoeffs( frange_FTN, dt );
end


% Build station directories
% @Siyu: added network to the file name instead of station only
for ipath = 1:length(PATHS)

    ccfR_path = [PATHS{ipath},'ccfRR/'];
    ccfT_path = [PATHS{ipath},'ccfTT/'];
    ccfZ_path = [PATHS{ipath},'ccfZZ/'];
    if ~exist([ccfR_path,net1,'-',sta1])
        mkdir([ccfR_path,net1,'-',sta1]);
    end
    if ~exist([ccfT_path,net1,'-',sta1])
        mkdir([ccfT_path,net1,'-',sta1]);
    end
    if ~exist([ccfZ_path,net1,'-',sta1])
        mkdir([ccfZ_path,net1,'-',sta1]);
    end
end

list1 = dir([datadir,'Data',net1,'/',sta1,'/*Z.sac']); % @Siyu: data path for station1

% ----- the second station in the pair ------
clear lat1 lat2 lon1 lon2 dist az baz vec_tz2 Z2raw vec_tz Z1raw


fprintf(log_file, 'performing cross-correlation for staion pair : %s %s\n', sta1, sta2);
% -------------loop through each half day--------------------
nday_stack=0;
coh_sumR = 0;
coh_sumT = 0;
coh_sumZ = 0;
coh_num = 0;

% Get a list of all available data
ihday = 0;
month_counter = 0;
imonth = 0;
    
nFile = floor(length(list1)); % list1 contains all file paths for station1
for ifil = 1:nFile % Can manipulate this number during the debug section 
try 
    file1cZ = list1(ifil).name;
    file1cH1 = strrep(file1cZ,'Z.sac','N.sac'); % switch N to 1 if using LH1 instead of LHN
    file1cH2 = strrep(file1cZ,'Z.sac','E.sac'); % switch E to 2 if using LH2 instead of LHE

    file2cZ = [file1cZ(1:end-7), '*Z.sac'];
    file2cZ = dir([datadir,'Data',net2,'/',sta2,'/',strrep(file2cZ,sta1,sta2)]);
    file2cH1 = [file1cH1(1:end-7), '*N.sac']; % switch N to 1 if using LH1 instead of LHN
    file2cH1 = dir([datadir,'Data',net2,'/',sta2,'/',strrep(file2cH1,sta1,sta2)]);
    file2cH2 = [file1cH2(1:end-7), '*E.sac']; % switch E to 2 if using LH2 instead of LHE
    file2cH2 = dir([datadir,'Data',net2,'/',sta2,'/',strrep(file2cH2,sta1,sta2)]);


    % Check that day file exists for station 2
    hdayid = erase(file1cZ(1:length(file1cZ)-8),sta1);
    hdayid = hdayid(2:end);
    if isempty(file2cZ) || isempty(file2cH1) || isempty(file2cH2)
        fprintf(log_file, ['No data for ',sta2,' on day ',hdayid,'... skipping']);
        continue
    end
    file2cZ = file2cZ.name;
    file2cH1 = file2cH1.name;
    file2cH2 = file2cH2.name;

    if month_counter == 0
        coh_sumR_month = 0;
        coh_sumT_month = 0;
        coh_sumZ_month = 0;
        coh_num_month = 0;
    end
    clear data1cH1 data1cH2 data1cZ data2cH1 data2cH2 data2cZ
    ihday = ihday +1;
    month_counter = month_counter + 1;
    clear temp
    %temp = strsplit(daylist1(ihday).name,'.');

    fprintf(log_file, ['Looking at ',hdayid,' ',sta2]);
        
    % can change N to 1 and E to 2 accordingly
    % data1cH1=dir([datadir,'Data',net1,'/',sta1,'/',sta1,'.',hdayid,'.*N.sac']);
    % data1cH2=dir([datadir,'Data',net1,'/',sta1,'/',sta1,'.',hdayid,'.*E.sac']);
    % data1cZ= dir([datadir,'Data',net1,'/',sta1,'/',sta1,'.',hdayid,'.*Z.sac']);
    % data2cH1=dir([datadir,'Data',net2,'/',sta2,'/',sta2,'.',hdayid,'.*N.sac']);
    % data2cH2=dir([datadir,'Data',net2,'/',sta2,'/',sta2,'.',hdayid,'.*E.sac']);
    % data2cZ= dir([datadir,'Data',net2,'/',sta2,'/',sta2,'.',hdayid,'.*Z.sac']);

    data1cH1 = [datadir,'Data',net1,'/',sta1,'/',file1cH1];
    data1cH2 = [datadir,'Data',net1,'/',sta1,'/',file1cH2];
    data1cZ =  [datadir,'Data',net1,'/',sta1,'/',file1cZ];
    data2cH1 = [datadir,'Data',net2,'/',sta2,'/',file2cH1];
    data2cH2 = [datadir,'Data',net2,'/',sta2,'/',file2cH2];
    data2cZ =  [datadir,'Data',net2,'/',sta2,'/',file2cZ];
    
    %------------------- TEST IF DATA EXIST------------------------
    [S1H1t,S1H1raw,~,S1H1tstart] = load_sac(data1cH1);
    [S1H2t,S1H2raw,~,S1H2tstart] = load_sac(data1cH2);
    [S1Zt,S1Zraw,S1,S1Ztstart] = load_sac(data1cZ);
    [S2H1t,S2H1raw,~,S2H1tstart] = load_sac(data2cH1);
    [S2H2t,S2H2raw,~,S2H2tstart] = load_sac(data2cH2);
    [S2Zt,S2Zraw,S2,S2Ztstart] = load_sac(data2cZ);

    % Make sure all times are relative to same reference point
    starttime = S1Ztstart;
    S1H1t = S1H1t + seconds(S1H1tstart-starttime);
    S1H2t = S1H2t + seconds(S1H2tstart-starttime);
    S1Zt = S1Zt + seconds(S1Ztstart-starttime);
    S2H1t = S2H1t + seconds(S2H1tstart-starttime);
    S2H2t = S2H2t + seconds(S2H2tstart-starttime);
    S2Zt = S2Zt + seconds(S2Ztstart-starttime);
        
    % Ensure that files have same start time to within 1 sample
    if abs(seconds(S1H1tstart-S2H1tstart))>S1.DELTA || abs(seconds(S1H2tstart-S2H2tstart))>S1.DELTA || abs(seconds(S1Ztstart-S2Ztstart))>S1.DELTA
        error('Station files do not have same start time');
    end

    %------------------- Remove instrument response ------------------------
    if IsRemoveIR
        pzfile1 = dir([PZpath,'SAC_PZs_*',sta1,'_*H1_*']); % PZ for H1 and H2 are identical
        pzfile2 = dir([PZpath,'SAC_PZs_*',sta2,'_*H1_*']);


        % do lazy checks to make sure only one PZ file is found for each station
        if length(pzfile1) ~= 1
            pzfile = pzfile1;

            % Figure out which response to read
            for ii = 1:length(pzfile)
                pzdate(ii) = doy2date(str2num(pzfile(ii).name(19:21)),str2num(pzfile(ii).name(14:17)));
            end
            otime = datenum(hdayid,'yyyymmddHHMMSS');
            ind = find(abs(otime-pzdate) == min(abs(otime-pzdate)));
            if ind > length(pzfile) & ind > 1
                ind = ind(end)-1;
            end
            pzfile = pzfile(ind);
            pzfile1 = pzfile;

        elseif length(pzfile2) ~= 1
            pzfile = pzfile2;

            % Figure out which response to read
            for ii = 1:length(pzfile)
                pzdate(ii) = doy2date(str2num(pzfile(ii).name(19:21)),str2num(pzfile(ii).name(14:17)));
            end
            otime = datenum(hdayid,'yyyymmddHHMMSS');
            ind = find(abs(otime-pzdate) == min(abs(otime-pzdate)));
            if ind > length(pzfile) & ind > 1
                ind = ind(end)-1;
            end
            pzfile = pzfile(ind);
            pzfile2 = pzfile;
        end
        dt_new = dt;

        % Read sacpz file for station 1
        [p,z,c] = read_SACPZ([PZpath,pzfile1.name]);

        dt1 = abs(S1H1t(1)-S1H1t(2));
        dt2 = abs(S2H1t(1)-S2H1t(2));

        % Remove instrument response for station 1 H1 & H2
        S1H1raw = rm_SACPZ(S1H1raw,z,p,c,dt1);
        S1H2raw = rm_SACPZ(S1H2raw,z,p,c,dt1);
        S1Zraw = rm_SACPZ(S1Zraw,z,p,c,dt1);

        % Read sacpz file for station 2
        [p,z,c] = read_SACPZ([PZpath,pzfile2.name]);

        % Remove instrument response for station 2 H1 & H2
        S2H1raw = rm_SACPZ(S2H1raw,z,p,c,dt2);
        S2H2raw = rm_SACPZ(S2H2raw,z,p,c,dt2);
        S2Zraw = rm_SACPZ(S2Zraw,z,p,c,dt2);
    end

    % Check to make sure there's actual data
    zeroind1 = find(S1H1raw == 0);
    zeroind2 = find(S2H1raw == 0);
    if length(zeroind1) == length(S1H1raw) || length(zeroind2) == length(S2H1raw)
        fprintf(log_file, 'All zeros!');
        continue
    end

    if(length(S1H1t)*length(S1H2t)*length(S1Zt)*length(S2H1t)*length(S2H2t)*length(S2Zt)==0)
        fprintf(log_file, ['no data for ! station ',sta2]);
        continue
    end

    % Determine the time span to cut to ... this will change with
    % different segments
    clear tcut
    minT1H1 = min(S1H1t);
    minT2H1 = min(S2H1t);
    minT1H2 = min(S1H2t);
    minT2H2 = min(S2H2t);
    minT1Z = min(S1Zt);
    minT2Z = min(S2Zt);

    if length(S1H1raw) < 30000 || length(S1H2raw) < 30000
        fprintf(log_file, ['Sta1 ',sta1,' : ',num2str(length(S1H2raw)),' is too short!']);
        continue
    elseif length(S2H1raw) < 30000 || length(S2H2raw) < 30000
        fprintf(log_file, ['Sta2 ',sta2,' : ',num2str(length(S2H2raw)),' is too short!']);
        continue
    end

    if(~exist('lat2','var'));

        S1 = readsac(data1cH1);
        S2 = readsac(data2cH1);

        lat1=S1.STLA;
        lon1=S1.STLO;
        dep1=S1.STEL; % depth is negative for OBS and positive for land stations


        lat2=S2.STLA;
        lon2=S2.STLO;
        dep2=S2.STEL; % depth is negative for OBS and positive for land stations


        % Get the interstation distance and azimuth
        [delta,S1az]=distance(lat1,lon1,lat2,lon2);
        [delta,S2az]=distance(lat2,lon2,lat1,lon1);

        dist=deg2km(delta);

        Delta=S1.DELTA;
        if(abs(Delta-dt) >= 0.01*dt )
            error('sampling interval does not match data! check dt');
        end

        if(dist < dist_min)
            display('distance shorter than 40 km, skip');
            break
        end
    end % if lat variabls

    stapairsinfo.stanames = {sta1,sta2};
    stapairsinfo.lats = [lat1,lat2];
    stapairsinfo.lons = [lon1,lon2];


    % START WINDOWING
    hour_length = winlength;

    nwin = floor(24/hour_length)*2-1; %
    win_length = hour_length*60*60*dt; % length of individual windows.
    win_start = 1;
    coh_sumT_day = 0;
    coh_sumR_day = 0;
    coh_sumZ_day = 0;
    coh_num_day = 0;
    last_pt = win_length*.5*(nwin-1)+1+Nstart*dt+win_length;
    if last_pt < length(S1H1raw)
        nwin = nwin + 1;
    end

    for iwin = 1: nwin
%               clear tcut S1R S2R S1T S2T S1Z S2Z fftS1R fftS2R fftS1T fftS2T fftS1Z fftS2Z

        % cut in time
        if hour_length == 24
            pts_begin = Nstart*dt;
            pts_end = length(S1H1raw)-Nstart*dt;
        else
            pts_begin = win_length*.5*(iwin-1)+1+Nstart*dt;
            pts_end = pts_begin+win_length;
        end

        if pts_begin > length(S1H1raw) || pts_begin > length(S2H1raw) || pts_end > length(S1H1raw) || pts_end > length(S2H1raw)
            fprintf(log_file, '(H1) Points greater than the data... fixing window');
            pts_begin = length(S1H1raw)-win_length-Nstart*dt;
            pts_end = pts_begin+win_length;
        elseif pts_begin > length(S1H2raw) || pts_begin > length(S2H2raw) || pts_end > length(S1H2raw) || pts_end > length(S2H2raw)
            fprintf(log_file, '(H2) Points greater than the data... fixing window');
            pts_begin = length(S1H2raw)-win_length-Nstart*dt;
            pts_end = pts_begin+win_length;
        elseif pts_begin > length(S1Zraw) || pts_begin > length(S2Zraw) || pts_end > length(S1Zraw) || pts_end > length(S2Zraw)
            fprintf(log_file, '(Z) Points greater than the data... fixing window');
            pts_begin = length(S1Zraw)-win_length-Nstart*dt;
            pts_end = pts_begin+win_length;
        end
        tcut = [pts_begin:dt:pts_end];

        % cut in tim H1 H2 for STA1
        S1H1=interp1(S1H1t,S1H1raw,tcut);
        S1H1(isnan(S1H1))=0;
        S1H2=interp1(S1H2t,S1H2raw,tcut);
        S1H2(isnan(S1H2))=0;
        S1Z=interp1(S1Zt,S1Zraw,tcut);
        S1Z(isnan(S1Z))=0;

        % cut in tim H1 H2 for STA2
        S2H1=interp1(S2H1t,S2H1raw,tcut);
        S2H1(isnan(S2H1))=0;
        S2H2=interp1(S2H2t,S2H2raw,tcut);
        S2H2(isnan(S2H2))=0;
        S2Z=interp1(S2Zt,S2Zraw,tcut);
        S2Z(isnan(S2Z))=0;

        %detrend
        if IsDetrend
            S1H1 = detrend(S1H1);
            S1H2 = detrend(S1H2);
            S1Z = detrend(S1Z);
            S2H1 = detrend(S2H1);
            S2H2 = detrend(S2H2);
            S2Z = detrend(S2Z);
        end

        % Apply cosine taper
        if IsTaper
            S1H1 = cos_taper(S1H1);
            S1H2 = cos_taper(S1H2);
            S1Z = cos_taper(S1Z);
            S2H1 = cos_taper(S2H1);
            S2H2 = cos_taper(S2H2);
            S2Z = cos_taper(S2Z);
        end
        
        % Apply prefilter
        if IsPrefilter
            [b,a] = butter(2,frange_prefilt*2*dt);
            S1H1 = FiltFiltM(b,a,S1H1);
            S1H2 = FiltFiltM(b,a,S1H2);
            S1Z =  FiltFiltM(b,a,S1Z);
            S2H1 = FiltFiltM(b,a,S2H1);
            S2H2 = FiltFiltM(b,a,S2H2);
            S2Z =  FiltFiltM(b,a,S2Z);
        end

        % ROTATE FROM H1-H2 TO R-T
        Ista = strcmp([net1, '-', sta1],slist);
        S1phi = orientations(Ista); % angle between H1 and N (CW from north)
        Ista = strcmp([net2, '-', sta2],slist);
        S2phi = orientations(Ista); % angle between H1 and N (CW from north)         
        if S1phi > 5  % correct the orientation if the error is greater than 5 degrees
            [S1R,S1T] = rotate_vector(S1H1,S1H2,S1az-S1phi);
        else
            [S1R,S1T] = rotate_vector(S1H1,S1H2,S1az);
        end
        if S2phi > 5
            [S2R,S2T] = rotate_vector(S2H1,S2H2,S2az-S2phi+180);
        else
            [S2R,S2T] = rotate_vector(S2H1,S2H2,S2az+180);
        end

        %---------------- Transverse Component --------------
        if IsFTN
            % Frequency-time normalization
            [ S1T ] = FTN( S1T, b, a );
            [ S2T ] = FTN( S2T, b, a );
            fftS1T = fft(S1T);
            fftS2T = fft(S2T);
        else
            if IsOBN
                % One-bit normalization
                S1T = runwin_norm(S1T);
                S2T = runwin_norm(S2T);
            end
            %fft
            fftS1T = fft(S1T);
            fftS2T = fft(S2T);
            %Whiten
            if IsSpecWhiten
                fftS1T = spectrumwhiten_smooth(fftS1T,0.001);
                fftS2T = spectrumwhiten_smooth(fftS2T,0.001);
            end
        end
        
        % calcaulate daily CCF and stack for transverse
        coh_trace = fftS1T .* conj(fftS2T);
        coh_trace = coh_trace ./ abs(fftS1T) ./ abs(fftS2T);
        coh_trace(isnan(coh_trace)) = 0;
        coh_sumT = coh_sumT + coh_trace;
        coh_trace_T = coh_trace;
        coh_sumT_day = coh_sumT_day + coh_trace;
        coh_sumT_month = coh_sumT_month + coh_trace;

        nanind = find(isnan(coh_trace));

        if length(nanind) == length(coh_trace)
            disp('All nan!');

            continue
        end


        %-------------------- Radial Component --------------
        if IsFTN
            % Frequency-time normalization
            [ S1R ] = FTN( S1R, b, a  );
            [ S2R ] = FTN( S2R, b, a  );
            fftS1R = fft(S1R);
            fftS2R = fft(S2R);
        else
            % One-bit Normalization
            if IsOBN
                S1R = runwin_norm(S1R);
                S2R = runwin_norm(S2R);
            end
            %fft
            fftS1R = fft(S1R);
            fftS2R = fft(S2R);
            %Whiten
            if IsSpecWhiten
                fftS1R = spectrumwhiten_smooth(fftS1R,0.001);
                fftS2R = spectrumwhiten_smooth(fftS2R,0.001);
            end
        end

        % calcaulate daily CCF and stack for radial
        coh_trace = fftS1R .* conj(fftS2R);
        coh_trace = coh_trace ./ abs(fftS1R) ./ abs(fftS2R);
        coh_trace(isnan(coh_trace)) = 0;
        coh_sumR = coh_sumR + coh_trace;
        coh_trace_R = coh_trace;
        coh_sumR_day = coh_sumR_day + coh_trace;
        coh_sumR_month = coh_sumR_month + coh_trace;

        %-------------------- Vertical Component --------------
        if IsFTN
            % Frequency-time normalization
            [ S1Z ] = FTN( S1Z, b, a  );
            [ S2Z ] = FTN( S2Z, b, a  );
            fftS1Z = fft(S1Z);
            fftS2Z = fft(S2Z);
        else
            % One-bit normalization
            if IsOBN
                S1Z = runwin_norm(S1Z);
                S2Z = runwin_norm(S2Z);
            end
            %fft
            fftS1Z = fft(S1Z);
            fftS2Z = fft(S2Z);
            %Whiten
            if IsSpecWhiten
                fftS1Z = spectrumwhiten_smooth(fftS1Z,0.001);
                fftS2Z = spectrumwhiten_smooth(fftS2Z,0.001);
            end
        end

        % calcaulate daily CCF and stack for radial
        coh_trace = fftS1Z .* conj(fftS2Z);
        coh_trace = coh_trace ./ abs(fftS1Z) ./ abs(fftS2Z);
        coh_trace(isnan(coh_trace)) = 0;
        coh_sumZ = coh_sumZ + coh_trace;
        coh_trace_Z = coh_trace;
        coh_sumZ_day = coh_sumZ_day + coh_trace;
        coh_sumZ_month = coh_sumZ_month + coh_trace;

        % coh_num = coh_num + 1;
        coh_num_day = coh_num_day + 1;
        coh_num_month = coh_num_month + 1;

        if IsOutputSinglestack % save individual xcor
            ccfT_singlestack_path = [ccf_singlestack_path,'ccfTT/'];
            ccfR_singlestack_path = [ccf_singlestack_path,'ccfRR/'];
            ccfZ_singlestack_path = [ccf_singlestack_path,'ccfZZ/'];
            save(sprintf('%s%s-%s/%s-%s_%s-%s_%d_f.mat',ccfT_singlestack_path,net1,sta1,net1,sta1,net2,sta2,coh_num),'coh_trace_T','stapairsinfo');
            save(sprintf('%s%s-%s/%s-%s_%s-%s_%d_f.mat',ccfR_singlestack_path,net1,sta1,net1,sta1,net2,sta2,coh_num),'coh_trace_R','stapairsinfo');
            save(sprintf('%s%s-%s/%s-%s_%s-%s_%d_f.mat',ccfZ_singlestack_path,net1,sta1,net1,sta1,net2,sta2,coh_num),'coh_trace_Z','stapairsinfo');
        end
    end % end window
    coh_num = coh_num + coh_num_day;

    if IsOutputDaystack
        % Save day stack
        daystr = datestr(starttime,'YYYYmmddHHMMSS');
        ccfT_daystack_path = [ccf_daystack_path,'ccfTT/'];
        ccfR_daystack_path = [ccf_daystack_path,'ccfRR/'];
        ccfZ_daystack_path = [ccf_daystack_path,'ccfZZ/'];
        clear coh_sum
        coh_sum = coh_sumT_day;
        save(sprintf('%s%s-%s/%s-%s_%s-%s_%s_f.mat',ccfT_daystack_path,net1,sta1,net1,sta1,net2,sta2,daystr),'coh_sum','coh_num_day','stapairsinfo','starttime');
        clear coh_sum
        coh_sum = coh_sumR_day;
        save(sprintf('%s%s-%s/%s-%s_%s-%s_%s_f.mat',ccfR_daystack_path,net1,sta1,net1,sta1,net2,sta2,daystr),'coh_sum','coh_num_day','stapairsinfo','starttime');
        clear coh_sum
        coh_sum = coh_sumZ_day;
        save(sprintf('%s%s-%s/%s-%s_%s-%s_%s_f.mat',ccfZ_daystack_path,net1,sta1,net1,sta1,net2,sta2,daystr),'coh_sum','coh_num_day','stapairsinfo','starttime');
    end
    if IsOutputMonthstack
        % Save 30 day (month) stack
        if month_counter == 30
            imonth = imonth + 1;
            ccfT_monthstack_path = [ccf_monthstack_path,'ccfTT/'];
            ccfR_monthstack_path = [ccf_monthstack_path,'ccfRR/'];
            ccfZ_monthstack_path = [ccf_monthstack_path,'ccfZZ/'];
            clear coh_sum
            coh_sum = coh_sumT_month;
            save(sprintf('%s%s-%s/%s-%s_%s-%s_month%d_f.mat',ccfT_monthstack_path,net1,sta1,net1,sta1,net2,sta2,imonth),'coh_sum','coh_num_month','stapairsinfo');
            clear coh_sum
            coh_sum = coh_sumR_month;
            save(sprintf('%s%s-%s/%s-%s_%s-%s_month%d_f.mat',ccfR_monthstack_path,net1,sta1,net1,sta1,net2,sta2,imonth),'coh_sum','coh_num_month','stapairsinfo');
            clear coh_sum
            coh_sum = coh_sumZ_month;
            save(sprintf('%s%s-%s/%s-%s_%s-%s_month%d_f.mat',ccfZ_monthstack_path,net1,sta1,net1,sta1,net2,sta2,imonth),'coh_sum','coh_num_month','stapairsinfo');
            month_counter = 0; % start over
        end
    end
    
catch
    % do nothing if error occurs, just skip to the next day
end % end exception handle
end % end hday (nFile)


% Finished looping all SAC files
output = ['Now we have finished windowing and CCF computing\n'];
timenow = datestr(datetime('now'));
fprintf(log_file, timenow);
fprintf(log_file, output);

if coh_num > 1
    if IsFigure1
        f101 = figure(101);clf;
        subplot(3,1,1)
        T = length(coh_sumR);
        faxis = [0:1/T:1/dt/2,-1/dt/2+1/T:1/T:-1/T];
        ind = find(faxis>0);
        plot(faxis(ind),smooth(real(coh_sumR(ind)/coh_num),10));
        title([net1,'-',sta1,'  ',net2,'-',sta2, sprintf(' coherency R ,station distance: %f km',dist)]); % @Siyu
        xlim([0.01 0.5])
        %xlim([0.04 0.16])
        xlabel('Frequency')

        subplot(3,1,2)
        T = length(coh_sumT);
        faxis = [0:1/T:1/dt/2,-1/dt/2+1/T:1/T:-1/T];
        ind = find(faxis>0);
        plot(faxis(ind),smooth(real(coh_sumT(ind)/coh_num),10));
        title([net1,'-',sta1,'  ',net2,'-',sta2, sprintf(' coherency T ,station distance: %f km',dist)]); % @Siyu
        xlim([0.01 0.5])
        %xlim([0.04 0.16])
        xlabel('Frequency')

        subplot(3,1,3)
        T = length(coh_sumZ);
        faxis = [0:1/T:1/dt/2,-1/dt/2+1/T:1/T:-1/T];
        ind = find(faxis>0);
        plot(faxis(ind),smooth(real(coh_sumZ(ind)/coh_num),10));
        title([net1,'-',sta1,'  ',net2,'-',sta2, sprintf(' coherency Z ,station distance: %f km',dist)]); % @Siyu
        xlim([0.01 0.5])
        %xlim([0.04 0.16])
        xlabel('Frequency')
        drawnow

        print(f101,'-dpsc',[fig_winlength_path,net1,'-',sta1,'_',net2,'-',sta2,'.ps']);

    end
    if IsOutputFullstack
        ccfT_fullstack_path = [ccf_fullstack_path,'ccfTT/'];
        ccfR_fullstack_path = [ccf_fullstack_path,'ccfRR/'];
        ccfZ_fullstack_path = [ccf_fullstack_path,'ccfZZ/'];
        clear coh_sum
        coh_sum = coh_sumT;
        save(sprintf('%s%s-%s/%s-%s_%s-%s_f.mat',ccfT_fullstack_path,net1,sta1,net1,sta1,net2,sta2),'coh_sum','coh_num','stapairsinfo');
        clear coh_sum
        coh_sum = coh_sumR;
        save(sprintf('%s%s-%s/%s-%s_%s-%s_f.mat',ccfR_fullstack_path,net1,sta1,net1,sta1,net2,sta2),'coh_sum','coh_num','stapairsinfo');
        clear coh_sum
        coh_sum = coh_sumZ;
        save(sprintf('%s%s-%s/%s-%s_%s-%s_f.mat',ccfZ_fullstack_path,net1,sta1,net1,sta1,net2,sta2),'coh_sum','coh_num','stapairsinfo');
    end
    if IsSaveTxt % @ Siyu: save the results in a txt file
        % List 1: lon1, la1, lon2, la2, distance
        list1 = [lon1, lat1, lon2, lat2, dist];

        %%% Z %%%
        T = length(coh_sumZ);
        faxis = [0:1/T:1/dt/2,-1/dt/2+1/T:1/T:-1/T];
        ind = find(faxis>0);
        % List 2: sample rate, # of days, snr acausal, snr causal, # of points in frequency domain
        list2 = [dt, ihday, 1.000, 2.000, length(faxis(ind))]; 
        % Z: frequency, real(ccf), imag(ccf), real(ccf), imag(ccf)
        Z = [faxis(ind); real(coh_sumZ(ind)/coh_num); imag(coh_sumZ(ind)/coh_num);
            real(coh_sumZ(ind)/coh_num); imag(coh_sumZ(ind)/coh_num)];
        % create txt file for Rayleigh Wave
        textpath_Z = [workingdir,'text_output/RayleighResponse/','dispersion_', net1,'-',sta1, '_', net2,'-',sta2, '.txt'];
        text_Z = fopen(textpath_Z, 'w');
        fprintf(text_Z, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', list1);
        fprintf(text_Z, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', list2);
        fprintf(text_Z, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', Z);
        fclose(text_Z);

        %%% T %%%
        T = length(coh_sumT);
        faxis = [0:1/T:1/dt/2,-1/dt/2+1/T:1/T:-1/T];
        ind = find(faxis>0);
        list2 = [dt, ihday, 1.000, 2.000, length(faxis(ind))]; 
        % T: (love) frequency, real(ccf), imag(ccf), real(ccf), imag(ccf)
        love = [faxis(ind); real(coh_sumT(ind)/coh_num); imag(coh_sumT(ind)/coh_num);
            real(coh_sumT(ind)/coh_num); imag(coh_sumT(ind)/coh_num)];
        % create txt file for Love Wave
        textpath_T = [workingdir,'text_output/LoveResponse/','dispersion_', net1,'-',sta1, '_', net2,'-',sta2, '.txt'];
        text_T = fopen(textpath_T, 'w');
        fprintf(text_T, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', list1);
        fprintf(text_T, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', list2);
        fprintf(text_T, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', love);
        fclose(text_T);

        %%% R %%%
        T = length(coh_sumR);
        faxis = [0:1/T:1/dt/2,-1/dt/2+1/T:1/T:-1/T];
        ind = find(faxis>0);
        list2 = [dt, ihday, 1.000, 2.000, length(faxis(ind))]; 
        % R: frequency, real(ccf), imag(ccf), real(ccf), imag(ccf)
        R = [faxis(ind); real(coh_sumR(ind)/coh_num); imag(coh_sumR(ind)/coh_num);
            real(coh_sumR(ind)/coh_num); imag(coh_sumR(ind)/coh_num)];
        % create txt file for Love Wave
        textpath_R = [workingdir,'text_output/RayleighResponse_R/','dispersion_', net1,'-',sta1, '_', net2,'-',sta2, '.txt'];
        text_R = fopen(textpath_R, 'w');
        fprintf(text_R, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', list1);
        fprintf(text_R, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', list2);
        fprintf(text_R, '%6.5f %6.5f %6.5f %6.5f %6.5f\n', R);
        fclose(text_R);
    end
end % end (if coh_num > 1)

    output = ['Now, we have finished the job\n'];
    timenow = datestr(datetime('now'));
    fprintf(log_file, timenow);
    fprintf(log_file, output);
    fclose(log_file);
end %end the function  

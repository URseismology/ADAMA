%%% Generate a clean version for AkiEstimate predicted phase velocity 
% Dec. 29, 2021 -- Siyu Xue

%%% Input files:
% predlove = the pv matrix for all exisitng pairs
% record = the index of pairs in the order of predlove
% names = name of stations
% infos = information about the station pairs: coordinations, distance....

%%% Output file: txt files, same format as Ekstrom USANET15 version
%    -- format (https://www.ldeo.columbia.edu/~ekstrom/Projects/ANT/USANT15/explain_USANT15_data.txt)

%% Load data

% wave type
wave = 'R';

% load med3 Aki results for the specific type: [LS, LL, RS, RL, RRS, RRL]
type = 'RL';
predlove = load(['/Users/sxue3/Documents/Figures/data/AkiResults/pv_med3_', type, '_110K.mat']).predlove;
recordpv = load(['/Users/sxue3/Documents/Figures/data/AkiResults/record_med3_', type, '.mat']).record;
preduncer = load(['/Users/sxue3/Documents/Figures/data/AkiResults/uncer_', type, '_110K.mat']).preduncer;
recordun = load(['/Users/sxue3/Documents/Figures/data/AkiResults/record_uncer_', type, '.mat']).record;
outliers = load(['/Users/sxue3/Documents/Figures/data/AkiOutliers/Med3_', type, '.mat']).outlier;

% load the name for stations: short [less] or long [greater] distance
dist = 'greater'; 
name_file = ['/Users/sxue3/Documents/CondaDir/myNbs/pp_analysis/ppConn_parts/sta', dist, '2000km.csv'];

A = readtable(name_file, 'Filetype','text');
sta1s = A{:,'Var1'};
sta2s = A{:,'Var2'};

% load other information about the station pair
T = readtable('/Users/sxue3/Documents/CondaDir/myNbs/pp_analysis/ADAMA_staconns.csv');
lat1 = T.lat1;
lat2 = T.lat2;
lon1 = T.lon1;
lon2 = T.lon2;
windows = T.x4hrWnd;
dists = T.distance_km;

clear T A

%% Select the row based on the Period
% Row numbers for uncertanity: 2521(5), 2041(6), 1441(8), 1081(10), 841(12), 601(15),
% 361(20), 217(25), 121(30), 52(35), 1(40)

% Row numbers for pv: 2880(5), 2400(6), 1800(8), 1440(10), 1200(12), 960(15),
% 720(20), 576(25), 480(30), 410(35), 360(40)
period = 40.0;

switch period
    case 5
        rpv = 2880;
        run = 2521;
    case 6
        rpv = 2400;
        run = 2041;
    case 8
        rpv = 1800;
        run = 1441;
    case 10
        rpv = 1440;
        run = 1081;
    case 12
        rpv = 1200;
        run = 841;
    case 15
        rpv = 960;
        run = 601;
    case 20
        rpv = 720;
        run = 361;
    case 25
        rpv = 576;
        run = 217;
    case 30
        rpv = 480;
        run = 121;
    case 35
        rpv = 410;
        run = 52;
    case 40
        rpv = 360;
        run = 1;
    otherwise
        disp('other value')
end


Ppvrow = predlove(rpv,:);
Punrow = preduncer(run, :);

%% ignore all outliers and get info for LL, LS, RS
[~,outidx] = intersect(recordpv,outliers,'stable');
index = ones(1,length(recordpv));
index(outidx) = 0;
record = recordpv(logical(index));  % logical array indicate if a pair is an outlier (0 = outlier)

sta1_col = sta1s(record);
sta2_col = sta2s(record);

lat1_col = lat1(record);
lat2_col = lat2(record);
lon1_col = lon1(record);
lon2_col = lon2(record);

window_col = windows(record);
dist_col = dists(record);

period_col = zeros(length(record),1) + period;

wave_col = zeros(length(record),1);
wave_col(:) = wave;  % will be stored in int, use fprintf('%s', i)

pv_col = Ppvrow(logical(index));
uncer_col = Punrow(logical(index));

%% For RL, because not all pairs have uncertanity results, it need to be treated differently
[~,outidx] = intersect(recordpv,outliers,'stable');
index = ones(1,length(recordpv));
index(outidx) = 0;
record = recordpv(logical(index));  % logical array indicate if a pair is an outlier (0 = outlier)

sta1_col = sta1s(record);
sta2_col = sta2s(record);

lat1_col = lat1(record);
lat2_col = lat2(record);
lon1_col = lon1(record);
lon2_col = lon2(record);

window_col = windows(record);
dist_col = dists(record);

period_col = zeros(length(record),1) + period;

wave_col = zeros(length(record),1);
wave_col(:) = wave;  % will be stored in int, use fprintf('%s', i)

pv_col = Ppvrow(logical(index));

new_uncer = [];
j = 1;
i = 1;
while i <= length(recordun)
    if recordun(i) == recordpv(j) % if the pair has uncertanity, add uncertanity
        new_uncer = [new_uncer, Punrow(i)];
        j = j + 1;
        i = i + 1;
    else
        new_uncer = [new_uncer, nan]; % if not, use nan
        j = j + 1;
    end
end

uncer_col = new_uncer(logical(index));
%% Save the columns to the desired format

% fprintf('%10s %10s %8.3f %8.3f %8.3f %8.3f %8.2f %7d %5.1f %s %7.3f %7.3f\n', ...
%     sta1_col{1}, sta2_col{1}, lat1_col(1), lon1_col(1), lat2_col(1), lon2_col(1), ...
%     dist_col(1), window_col(1), period_col(1), wave_col(1), pv_col(1), uncer_col(1));

fileID = fopen(['./data/ADAMA_pvclean/long_', num2str(period),'_', wave, '.txt' ],'w');
for i = 1:length(lat2_col)
    fprintf(fileID, '%10s %10s %8.3f %8.3f %8.3f %8.3f %8.2f %7d %5.1f %s %7.3f %7.3f\n', ...
    sta1_col{i}, sta2_col{i}, lat1_col(i), lon1_col(i), lat2_col(i), lon2_col(i), ...
    dist_col(i), window_col(i), period_col(i), wave_col(i), pv_col(i), uncer_col(i));
end
fclose(fileID);

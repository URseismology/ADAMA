% Plot the distribution of phase velocity from Med2, Med3, and their outliers
% Also, plot the distribution of difference between each pair's Med3 and Med2 results
% Input data are generated on Bluehive in Prj5/3_Src/fig7_getAkiData.m
% The code fig7_getAkiData.m will also be uploaded to Google Drive
% Nov. 10, 2021 -- Siyu Xue

%% Load in data
type = 'LS';
% load the med2 and med3 Aki results for the specific type: [LS, LL, RS, RL]
med2 = load(['/Users/sxue3/Documents/Figures/data/AkiResults/pv_Med2_', type, '_110K.mat']).predlove;
med3 = load(['/Users/sxue3/Documents/Figures/data/AkiResults/pv_Med3_', type, '_110K.mat']).predlove;
med2_record = load(['/Users/sxue3/Documents/Figures/data/AkiResults/record_Med2_', type, '.mat']).record;
med3_record = load(['/Users/sxue3/Documents/Figures/data/AkiResults/record_Med3_', type, '.mat']).record;
med2_outlier = load(['/Users/sxue3/Documents/Figures/data/AkiOutliers/Med2_', type, '.mat']).outlier;
med3_outlier = load(['/Users/sxue3/Documents/Figures/data/AkiOutliers/Med3_', type, '.mat']).outlier;
%% Extra PV at specific periods with outliers

%%%%% Period = 5
P5m2 = [];
pvfreq = linspace(0, 0.5, 7200);
[~,pairs] = size(med2);
P5_keep = [];

% Loop are pairs whoes row 2640 is non-zero (for P=5)
for i = 1:pairs
    if med2(2880, i) > 0  % if there is value for P=5, just take the number
        P5m2 = [P5m2 med2(2880, i)];
        P5_keep = [P5_keep i];
    elseif med2(2640, i) > 0
        pvpair = med2(:, i);  
        nonZero = find(med2(:,1));
        freq = linspace(nonZero(1)*0.5/7200, 0.2, 500);  % extrapolate from the first non-zero point to 0.2
        P5 = interp1(pvfreq(pvpair>0), pvpair(pvpair>0), freq, 'nearest', 'extrap');
        P5m2 = [P5m2 P5(end)];
        P5_keep = [P5_keep i];
    end
end

P5m3 = med3(2880,:);

%%%%% Period = 10
P10m2row = med2(1440,:);
P10m2 = P10m2row(P10m2row>0);
P10m3 = med3(1440,:);

%%%%% Period = 13 (freq = 0.07692)
P13m2row = med2(1108,:);
P13m2 = P13m2row(P13m2row>0);
P13m3 = med3(1108,:);

%%%%% Period = 20
P20m2row = med2(720,:);
P20m2 = P20m2row(P20m2row>0);
P20m3 = med3(720,:);

%%%%% Period = 40
P40m2 = [];
P40_keep = [];
% Loop are pairs whoes row 385 is non-zero (for P=40)
for i = 1:pairs
    if med2(360, i) > 0
        P40m2 = [P40m2 med2(360, i)];
        P40_keep = [P40_keep i];
    elseif med2(385, i) > 0
        pvpair = med2(:, i);
        nonZero = find(med2(:,1));
        freq = linspace(0.025, nonZero(end)*0.5/7200, 500);
        P40 = interp1(pvfreq(pvpair>0), pvpair(pvpair>0), freq, 'nearest', 'extrap');
        P40m2 = [P40m2 P40(1)];
        P40_keep = [P40_keep i];
    end
end

P40m3 = med3(360,:);

% create grouped data

grp1m2 = [P40m2 P20m2 P13m2 P10m2 P5m2];
grp2m2 = [(zeros(length(P40m2),1)+1).' (zeros(length(P20m2),1)+2).' (zeros(length(P13m2),1)+3).'...
    (zeros(length(P10m2),1)+4).' (zeros(length(P5m2),1) + 5).'];

grp1m3 = [P40m3 P20m3 P13m3 P10m3 P5m3];
grp2m3 = [(zeros(length(P40m3),1)+1).' (zeros(length(P20m3),1)+2).' (zeros(length(P13m3),1)+3).'...
    (zeros(length(P10m3),1)+4).' (zeros(length(P5m3),1) + 5).'];

%% Extra PV at specific periods WITHOUT outliers

med2_remove = [];
med3_remove = [];
med2_record_no = med2_record;
med3_record_no = med3_record;

% generate med2 and med3 without outliers
for i = 1:length(med2_outlier)
    
    temp = find(med2_record == med2_outlier(i));
    med2_remove = [med2_remove temp];
    med2_record_no(med2_record_no == med2_outlier(i)) = [];

end

for i = 1:length(med3_outlier)
    
    temp = find(med3_record == med3_outlier(i));
    med3_remove = [med3_remove temp];
    med3_record_no(med3_record_no == med3_outlier(i)) = [];

end

med2(:, med2_remove) = [];
med3(:, med3_remove) = [];


%%%%% Period = 5
P5m2_no = [];
pvfreq = linspace(0, 0.5, 7200);
[~,pairs] = size(med2);
% Loop are pairs whoes row 2640 is non-zero (for P=5)
for i = 1:pairs
    if med2(2880, i) > 0  % if there is value for P=5, just take the number
        P5m2_no = [P5m2_no med2(2880, i)];
    elseif med2(2640, i) > 0
        pvpair = med2(:, i);  
        nonZero = find(med2(:,1));
        freq = linspace(nonZero(1)*0.5/7200, 0.2, 500);  % extrapolate from the first non-zero point to 0.2
        P5 = interp1(pvfreq(pvpair>0), pvpair(pvpair>0), freq, 'nearest', 'extrap');
        P5m2_no = [P5m2_no P5(end)];
    end
end

P5m3_no = med3(2880,:);

%%%%% Period = 10
P10m2row = med2(1440,:);
P10m2_no = P10m2row(P10m2row>0);
P10m3_no = med3(1440,:);

%%%%% Period = 13 (freq = 0.07692)
P13m2row = med2(1108,:);
P13m2_no = P13m2row(P13m2row>0);
P13m3_no = med3(1108,:);

%%%%% Period = 20
P20m2row = med2(720,:);
P20m2_no = P20m2row(P20m2row>0);
P20m3_no = med3(720,:);

%%%%% Period = 40
P40m2_no = [];
% Loop are pairs whoes row 385 is non-zero (for P=40)
for i = 1:pairs
    if med2(360, i) > 0
        P40m2_no = [P40m2_no med2(360, i)];
    elseif med2(385, i) > 0
        pvpair = med2(:, i);
        nonZero = find(med2(:,1));
        freq = linspace(0.025, nonZero(end)*0.5/7200, 500);
        P40 = interp1(pvfreq(pvpair>0), pvpair(pvpair>0), freq, 'nearest', 'extrap');
        P40m2_no = [P40m2_no P40(1)];
    end
end

P40m3_no = med3(360,:);

% create grouped data

grp1m2_no = [P40m2_no P20m2_no P13m2_no P10m2_no P5m2_no];
grp2m2_no = [(zeros(length(P40m2_no),1)+1).' (zeros(length(P20m2_no),1)+2).' (zeros(length(P13m2_no),1)+3).'...
    (zeros(length(P10m2_no),1)+4).' (zeros(length(P5m2_no),1) + 5).'];

grp1m3_no = [P40m3_no P20m3_no P13m3_no P10m3_no P5m3_no];
grp2m3_no = [(zeros(length(P40m3_no),1)+1).' (zeros(length(P20m3_no),1)+2).' (zeros(length(P13m3_no),1)+3).'...
    (zeros(length(P10m3_no),1)+4).' (zeros(length(P5m3_no),1) + 5).'];

%% Compute the C_f - C_0 (Med3 - Med2) for all 5 periods

record_intersc = intersect(med2_record_no, med3_record_no);
N = length(record_intersc);
P5_diff = nan(1, N);
P10_diff = nan(1, N);
P13_diff = nan(1, N);
P20_diff = nan(1, N);
P40_diff = nan(1, N);

for i = 1:length(record_intersc)
    try
        P5_diff(1,i) = P5m3_no(med3_record_no == record_intersc(i))  - P5m2_no(find(med2_record_no == record_intersc(i)));
    catch
    end

    try
        P10_diff(1,i) = P10m3_no(med3_record_no == record_intersc(i))  - P10m2_no(find(med2_record_no == record_intersc(i)));
    catch
    end

    try
        P13_diff(1,i) = P13m3_no(med3_record_no == record_intersc(i))  - P13m2_no(find(med2_record_no == record_intersc(i)));
    catch
    end
        
    try
        P20_diff(1,i) = P20m3_no(med3_record_no == record_intersc(i))  - P20m2_no(find(med2_record_no == record_intersc(i)));
    catch
    end

    try
        P40_diff(1,i) = P40m3_no(med3_record_no == record_intersc(i))  - P40m2_no(find(med2_record_no == record_intersc(i)));
    catch
    end
end

P5_diff = (P5_diff(~isnan(P5_diff)));
P10_diff = (P10_diff(~isnan(P10_diff)));
P13_diff = (P13_diff(~isnan(P13_diff)));
P20_diff = (P20_diff(~isnan(P20_diff)));
P40_diff = (P40_diff(~isnan(P40_diff)));

grp1_diff = [P40_diff P20_diff P13_diff P10_diff P5_diff];
grp2_diff = [(zeros(length(P40_diff),1)+1).' (zeros(length(P20_diff),1)+2).' (zeros(length(P13_diff),1)+3).'...
    (zeros(length(P10_diff),1)+4).' (zeros(length(P5_diff),1) + 5).'];

%% Plot the boxplots

% initialize some parameters
DeviceColors = {'r' 'b' 'g'};
legendEntries = {'Outliers','C_0' '' 'C_f' 'C_f - C_0'};
Periods = {'40' '20' '13' '10' '05'};
Freqs = {'25' '50' '77' '100' '200'};
N = 3;
delta = linspace(-.4,.4,5); %// define offsets to distinguish plots
width = eps; %// small width to avoid overlap
cmap = hsv(N); %// colormap
legWidth = 2.3; %// make room for legend


% plot all boxplots
for ii=1:N 
    labels = Periods; 
    hold on

    if ii == 1  %% plotting Med2 results
        yyaxis left
        boxplot(grp1m2, grp2m2,'Color', [0.5 0.5 0.5], 'boxstyle','filled', ...
        'position',(1:5)+delta(ii), 'widths',width, 'labels',labels, 'symbol', 'o', ...
        'outliersize', 1.0, 'whisker', 0,  'notch', 'off');
        medians = [nanmedian(P40m2) nanmedian(P20m2) nanmedian(P13m2) nanmedian(P10m2) nanmedian(P5m2)];
        
        boxplot(grp1m2_no, grp2m2_no,'Color', DeviceColors{ii}, 'boxstyle','filled', ...
        'position',(1:5)+delta(ii), 'widths',width, 'labels',labels, 'symbol', 'o', ...
        'outliersize', 1.0, 'whisker', 0,  'notch', 'off');
        medians_no = [nanmedian(P40m2_no) nanmedian(P20m2_no) nanmedian(P13m2_no) nanmedian(P10m2_no) nanmedian(P5m2_no)];

        pp = plot((1:5)+delta(ii), medians, 'ro');
        pp.MarkerFaceColor = [0.5 0.5 0.5];
        pp.MarkerEdgeColor = 'k';
        pp.MarkerSize = 10;
    elseif ii == 2  %% plotting Med3 results
        yyaxis left
        boxplot(grp1m3, grp2m3,'Color', [0.5 0.5 0.5], 'boxstyle','filled', ...
        'position',(1:5)+delta(ii), 'widths',width, 'labels',labels, 'symbol', 'o', ...
        'outliersize', 1.0, 'whisker', 0,  'notch', 'off');
        medians = [nanmedian(P40m3) nanmedian(P20m3) nanmedian(P13m3) nanmedian(P10m3) nanmedian(P5m3)];
        
        boxplot(grp1m3_no, grp2m3_no,'Color', DeviceColors{ii}, 'boxstyle','filled', ...
        'position',(1:5)+delta(ii), 'widths',width, 'labels',labels, 'symbol', 'o', ...
        'outliersize', 1.0, 'whisker', 0,  'notch', 'off');
        medians_no = [nanmedian(P40m3_no) nanmedian(P20m3_no) nanmedian(P13m3_no) nanmedian(P10m3_no) nanmedian(P5m3_no)];
    
        pp = plot((1:5)+delta(ii), medians, 'ro');
        pp.MarkerFaceColor = [0.5 0.5 0.5];
        pp.MarkerEdgeColor = 'k';
        pp.MarkerSize = 10;

    elseif ii == 3  %% plotting C_f - C_0
        yyaxis right
        boxplot(grp1_diff, grp2_diff,'Color', DeviceColors{ii}, 'boxstyle','filled', ...
        'position',(1:5)+delta(ii), 'widths',width, 'labels',labels, 'symbol', 'o', ...
        'outliersize', 1.0, 'whisker', 0,  'notch', 'off');
        medians_no = [nanmedian(P40_diff) nanmedian(P20_diff) nanmedian(P13_diff) nanmedian(P10_diff) nanmedian(P5_diff)];
    end

    
    pp_no = plot((1:5)+delta(ii), medians_no, 'ro');
    pp_no.MarkerFaceColor = DeviceColors{ii};
    pp_no.MarkerEdgeColor = 'k';
    pp_no.MarkerSize = 10;
end

grid on;
%legend(legendEntries, 'Location', 'southwest','fontsize',10);

yyaxis left
ylabel('Phase Velocity (km/s)','fontsize',15);
ylim([0 7]);
text(0.4, 1.2,'(a)','fontsize',25);

yyaxis right
ylabel('C_f - C_0 (km/s)','fontsize',15);
ylim([-3 3]);

xlabel('Period (s)','fontsize',15);
set(gca,'XAxisLocation','top','LineWidth',1);  % make the x-axis on top 

% xlabel('Frequency (mHz)','fontsize',15);

% save the figure in PDF format
fig = gcf;
saveFig('fig8_pvDiff_LS.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);


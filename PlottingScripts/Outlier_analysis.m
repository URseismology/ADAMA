% Dr.O's code for finding (top) networks contributing to outliers
% Results will be used in fig10 plotting

% Read in outlier pair lists
lovecf = load('/Users/sxue3/Documents/Figures/data/AkiOutliers/Med3_Love_pair.mat');
ralcf = load('/Users/sxue3/Documents/Figures/data/AkiOutliers/Med3_Rayleigh_pair.mat');
cfs = ralcf.outlier_pair;

% 
clc
cftab = cell2table(cfs);

%
clc
usta = unique(cfs);

Npair = height(cftab);
Nsta = length(usta);

sta1 = table2cell(cftab(:,1));
sta2 = table2cell(cftab(:,2));

nets1 =cell(length(sta1), 1);

for ista = 1:length(sta1)
    
    strvals = strsplit(sta1{ista}, '-');
    nets1{ista} = strvals{1};
end

cntPairs = zeros(Nsta, 1);
for iSta = 1: Nsta
    
    cntPairs(iSta) =sum(strcmp(sta2, usta{iSta}) | strcmp(sta1, usta{iSta}));
end

unet = unique(nets1);
nNet = length(unet);
cntNetPairs = zeros(nNet, 1);
for iNet = 1: nNet
    
    cntNetPairs(iNet) =sum(strcmp(nets1, unet{iNet}) );
end

[s, indsort] = sort(cntNetPairs, 'descend');
unet{indsort(1:10)}

%% 
sortcnt = cntNetPairs(indsort);
sum(sortcnt(1:9)/sum(cntNetPairs))  % top 10 (or 9) worst networks are responsible to 80% outliers
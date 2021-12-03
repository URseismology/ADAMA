% This code plots three heatmaps:
% (1) heatmap for # of records of all stations and years
% (2) heatmap for the Top50 stations
% (3) heatmap for networks (most important)

%% (1) heatmap for # of records of all stations and years
map = readmatrix('/Users/sxue3/Documents/Figures/data/heatmap.csv');
nmap = map(2:end, 2:end) ./ max(map(2:end, 2:end), [], 'all') .* 100;  % convert the number of records to % of data avaliable
amap = map(2:end, 2:end);  % for calculating the cumulative sum

figure(1)
clf
subplot(10,1,2:10)

stav = sum(nmap, 2);
[srtstav, indsort ] = sort(stav, 'descend');
ordmap = nmap(indsort, :);
aordmap = amap(indsort, :);

im1 = imagesc(ordmap);
grid on;
ax = gca; % Get handle to current axes
ax. GridColor = [1, 1, 1];  % set the grid color
ax.GridAlpha = 0.6;  % set the grid lines transparency
ax.LineWidth = 2;
h = colorbar('southoutside');
ylabel(h, '% Data Available', 'Fontsize', 14);
ylabel('All Stations Avaliable', 'Fontsize', 14);

[nsta,nyrs] = size(ordmap);
xt = 5:5:nyrs;
labelt = map(1, 2:end);
xlab = string(labelt(xt));
xticklabels(xlab);

% plot the line chart on the top
subplot(10,1,1)
staSum = sum(aordmap);
cumSum = cumsum(staSum);
%logcumSum = log(cumSum)./log(10);

plot(cumSum, 'Linewidth', 3);
xticks(xt);
xticklabels(xlab);
xlim([1 41]); ylim([-100000 1e6]);
grid on
ylabel('c-sum','fontsize',14);
title('All Pre-Processed Stations', 'Fontsize', 15);

x0=10;
y0=10;
width=500;
height=750;
set(gcf,'position',[x0,y0,width,height]);

fig = gcf;
% saveFig('fig1c_allStaHeat.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
%% (2) heatmap for the Top50 stations
ordmap = nmap(indsort, :);
figure(2)
clf
im2 = imagesc(ordmap);
ylim([0 50])
grid on

labelt = map(1, 2:end);
dat = readtable('/Users/sxue3/Documents/Figures/data/heatmap.csv');
stalabels = dat.Var1; stalabels = stalabels(2:end);
ordstalbl = stalabels(indsort);

[nsta,nyrs] = size(ordmap);
 
nnsta = 50;
xt = 5:5:nyrs;
yt = 1:1:nnsta;
xlab = string(labelt(xt));
 
ax = gca;
ax.GridColor = [1, 1, 1];
ax.LineWidth = 2;
ax.GridAlpha = 0.6;  % set the grid lines transparency

xticks(xt); yticks(yt);
xticklabels(xlab);
yticklabels(ordstalbl(1:nnsta));
ylim([yt(1) yt(end)]);
title('Top 50 stations on network');

h = colorbar('southoutside');
ylabel(h, '% Data Available', 'Fontsize', 14);
 
% new = copyobj(gca, gcf);
% set(new,'YAxisLocation','right');
 
%hold on
%axes('YAxisLocation', 'right')
 
%% (3) heatmap for networks

% netHeatmap.csv includes:
% -- record counts per year per network
% -- station counts per network
% -- network names

% netHeatmap.csv: counting records based on downloaded data
% ppnetHeatmap.csv: counting records based on pre-processed data

% get the y-axis labels (list of networks)
dat = readtable('/Users/sxue3/Documents/Figures/data/netHeatmap.csv'); % use ppnetHeatmap.csv if plotting pp data
netlabels = dat.Var43; netlabels = netlabels(2:end);  % network labels

% get the actural data abd x-axis labels (list of years)
dat = readmatrix('/Users/sxue3/Documents/Figures/data/netHeatmap.csv');
labelt = dat(1, 1:end-2);  % year labels
map = dat(2:end, 1:end-2);
staCnt = dat(2:end, end-1);

% to get the location of the heatmap subplot
loca = [];
for i = 1:9
    temp = 10*i + [1,2,3,4,5,6,7,8,9];
    loca = [loca, temp];
end
subplot(10,10, loca)
im3 = imagesc(map);
text(1,61,'(b)','fontsize',15,'Color','w');
[nnet,nyrs] = size(map);
xt = 5:5:nyrs;
yt = 1:1:nnet;
xlab = string(labelt(xt));
xticks(xt); 
yticks(yt);
xticklabels(xlab);
yticklabels(netlabels(1:nnet));

grid on
ax = gca;
ax.GridColor = [1, 1, 1];
ax.LineWidth = 1;
ax.GridAlpha = 0.6;  % set the grid lines transparency

h = colorbar('southoutside');
ylabel(h, 'Record average per year', 'Fontsize', 14);

% set the size of the plot
x0=10;
y0=10;
width=550;
height=850;
set(gcf,'position',[x0,y0,width,height]);

% make a copy of the plot so t-axis labels are also on the right
% new = copyobj(gca, gcf);
% set(new,'YAxisLocation','right');

% create the line chart on top (ccumulative sum)
subplot(10,10,1:9)
plot(cumSum, 'Linewidth', 3);
xticks(xt);
xticklabels(xlab);
xlim([1 41]); ylim([-100000 1e6]);
grid on
ylabel('c-sum','fontsize',14);
title('All Downloaded Networks', 'Fontsize', 15);
text(1.5,8e5,'(a)','fontsize',15);

% create the heatmap for the station count of each network
subplot(10,10,[20,30,40,50,60,70,80,90,100])
im4 = imagesc(staCnt);
xticks(1.25); 
xticklabels(['Station count']); 
yt = 1:1:nnet;
yticks(yt);
yticklabels(netlabels(1:nnet));
set(gca,'YAxisLocation','right');
colormap(gca, 'jet');
colorbar('southoutside');
title("(c) ", 'fontsize', 15,'FontWeight','Normal');

% save the figure to pdf
fig = gcf;
saveFig('fig1c_allNetHeat.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
% Plot the African map with station marked on them
% Top station are marked using special markers
% This code uses m_map and geoData
% Input files: ppconnCnt.csv and African craton file


%% Read in Data
dat = readtable('/Users/sxue3/Documents/Figures/data/ppconnCnt.csv');
stas = dat.Station;
nets = dat.Network;
nSta = length(stas);
lats = dat.Latitude;
lons = dat.Longitude;
connCnt = dat.connCnt;

% assign network markers to top stations  (connection > 650)
topCnt = 38;  % stations other than the tops will have black '+' as the marker
isyms = zeros(nSta, 1);
for iSta = 1: topCnt
        net = nets(iSta);
        sta = stas(iSta);
        
        switch net{1}
            case 'GT'
                isyms(iSta) = 1;
            case 'IU'
                isyms(iSta) = 2;
            case 'AF'
                isyms(iSta) = 3;
            case 'G'
                isyms(iSta) = 4;
            case 'MN' 
                isyms(iSta) = 5;
            case 'II'
                isyms(iSta) = 6;
            case 'ES'
                isyms(iSta) = 7;
        end
end
isyms((topCnt+1):end) = isyms((topCnt+1):end) + 8;  % other stations will have the 7th marker

%% Plot the topo of Africa
addpath('/Users/sxue3/Documents/Figures/m_map');
fs = 18;  % font size
clc

% plot map with topo
clf

m_proj('lambert','lon',[-26 58.12],'lat',[-36 40]);  % African boundaries
m_grid('linestyle','none','tickdir','out','linewidth',3);
[CS,CH]=m_etopo2('contourf',[-6000:500:0 250:250:3000],'edgecolor','none');
colormap([ m_colmap('blues',80); flipud( gray(48) ) ]);
topoax = m_contfbar(0.98,[.17 .79],CS,CH); set(topoax,'fontsize',(fs-1));
ylabel(topoax, 'Topography km');

hold on;

% Plot the boundary lines and cratons
% -- boundary
fname = '/Users/sxue3/Documents/Figures/geoData/AfricaCoast.mat';
afcoast = load(fname);
aflon = wrapTo180(afcoast.XY(:,1));
aflat = afcoast.XY(:,2);
m_line(aflon,aflat,'color','k','linewi',2);
 
% -- cratons
AC = load('/Users/sxue3/Documents/Figures/data/cratons/AfricanCratons.mat');
latCongo = AC.Congo(:,1);
lonCongo = AC.Congo(:,2);
latKala = AC.Kala(:,1);
lonKala = AC.Kala(:,2);
latSahara = AC.Sahara(:,1);
lonSahara = AC.Sahara(:,2);
latTanza = AC.Tanza(:,1);
lonTanza = AC.Tanza(:,2);
latWest = AC.West(:,1);
lonWest = AC.West(:,2);
latZim = AC.Zim(:,1);
lonZim = AC.Zim(:,2);
% plot cratons
m_line(lonCongo, latCongo, 'color','k','linewi',2);
m_line(lonKala, latKala, 'color','k','linewi',2);
m_line(lonSahara, latSahara, 'color','k','linewi',2);
m_line(lonTanza, latTanza, 'color','k','linewi',2);
m_line(lonWest, latWest, 'color','k','linewi',2);
m_line(lonZim, latZim, 'color','k','linewi',2);


% Plot the stations with different symbols
symbs = {'o', 's', 'v', 'd', '^', 'p', 'h', '+'};  % marker types
sze = [10, 10, 10, 10, 10, 10, 10, 4];  % marker sizes

% -- set the color of each station marker
nCols = 100;
cols = m_colmap('jet',nCols); c = zeros(nCols, 4);
datR = linspace(650, 1208, nCols);

for i = 1:nCols
    c(i, :) = [datR(i) cols(i,:)];
end
    
for iSta = 1 : nSta
    lat = lats(iSta);
    lon = lons(iSta);
    
    indcol = find(connCnt(iSta)  <= c(:,1),1);
        
        if indcol
            mfc = c(indcol, 2:4);
        else
            mfc = c(end, 2:4);
        end
        
    ax =  m_line(lon, lat, 'marker',symbs{isyms(iSta)}, ...
        'color','k','linewi',1,...
        'linest','none','markersize',sze(isyms(iSta)),'markerfacecolor',mfc);
end

% create a legend for the markers
hh = [];
for is = 1:length(symbs)
    hh(is) = m_line(-90, 40, 'marker',symbs{is}, ...
        'markersize',13, 'color','k','linewi',1, 'linest','none');
end

m_gshhs('fb2', 'color','k', 'linewidth', .1);
legend(hh, 'GT','IU','AF','G', 'MN', 'II', 'ES', 'Others', 'Location', 'SouthEast', ...
    'fontsize', (fs-2), 'Position', [0.13, 0.13, 0.1, 0.2]);

%
ax1 = axes;
ax1.Visible = 'off';
colormap(ax1, m_colmap('jet',nCols));

% create the color bar for the # of connections of the top stations
ticR = 0:0.1:1; lenR = length(ticR);
ticL = floor(linspace(datR(1), datR(end), lenR));
ah = colorbar('Ticks',ticR, 'TickLabels', ticL, 'Position', [0.79, 0.2, 0.02, 0.6],'Fontsize', fs);
ylabel(ah, 'No. Connections', 'fontsize', fs+1);

% set the size of the plot
x0=10;
y0=10;
width=1500;
height=700;
set(gcf,'position',[x0,y0,width,height]);

% save the figure
% fig = gcf;
% saveFig('fig2_AfrStaQlty_pp.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
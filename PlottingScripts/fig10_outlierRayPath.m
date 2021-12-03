%%% The code is very similar to fig2_RayPath_Density.m
% Data for this plot were generated in Prj5/4_Bin/figs4/Fig_RayPathDenrity.m
% from the begining until section 7 (right before plotting)
% the final result is a stacking of raypath, plate boundaries, and network centers
% Need to combine them together in Adobe Illustrator. 
% Nov. 22, 2021

figure
clf

%% Plot the ray path density of the outlier pairs
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

addpath('/Users/sxue3/Documents/Figures/m_map/');

for iFace = 1 : nFaces
    face = vMat(fMat(iFace,:), :);
    [flon, flat, fr] = cart2sph(face(:,1), face(:,2), face(:,3) );
    flat = rad2deg(flat); mflat = mean(flat);
    flon = rad2deg(flon); mflon = mean(flon);
    
    faceStat(iFace, 1:2) = [mflon, mflat];
    %faceStat(iFace, 3) = faceStat(iFace, 3) ./ 5;

end

% visualize count ... 
sz = .24;
lond = -180:sz:180;
latd = -90:sz:90;

[dlon, dlat] = meshgrid(lond, latd);

test = faceStat(:,3);

test(test==0)=NaN;

F = scatteredInterpolant(faceStat(:,1), faceStat(:,2), ...
     log(test) , 'natural' );
 
ytit = 'log(Raypaths)';
crange = [0.4 1.2];
fval = F(dlon, dlat) ;
text(-0.3, -0.53,'(b)','fontsize',30);

% -- plot face count
%latlim = [-36 40]; lonlim = [-18 57]; % the whole Africa
latlim = [-36 40];
lonlim = [-18 57];
m_proj('miller', 'lat',latlim, 'lon', lonlim );
m_grid('xtick',[],'ytick',[],'linestyle','-');
hold on
m_pcolor(dlon, dlat, fval)
cmap = 'default'; colormap(cmap);
caxis([0, 7]);
y = colorbar('eastoutside', 'fontsize', 20); 
ylabel(y, ytit, 'fontsize', 25);

m_coast();

% plot countries and cratons
for iCntry = 1:length(S1)
    m_line([S1(iCntry).X], [S1(iCntry).Y], 'color', [0.5 0.5 .5], 'linewi',2);  % states ...
end
        

% plot cratons
% m_line(lonCongo, latCongo, 'color','k','linewi',2);
% m_line(lonKala, latKala, 'color','k','linewi',2);
% m_line(lonSahara, latSahara, 'color','k','linewi',2);
m_line(lonTanza, latTanza, 'color','k','linewi',2);
% m_line(lonWest, latWest, 'color','k','linewi',2);
% m_line(lonZim, latZim, 'color','k','linewi',2);

m_line(aflon,aflat,'color','k','linewi',2);

% set the size of the plot
x0=10;
y0=10;
width=500;
height=700;
set(gcf,'position',[x0,y0,width,height]);

% save the plot in PDF format
fig = gcf;
saveFig('fig10_outlierRayPathRayleigh.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);

%% Plot the outlier network center: Love
% The top outlier networks are found in the Outlier_analysis.m code

%%%% Networks have the most outliers in Love %%%%
% Plot the stations with different symbols
symbs = {'s', 'o','o','s', '^','v', 'o', '^', 'd'};  % marker types
colors = {'m', 'b','c', 'b','r','r','r','c','m'};
sze = [10, 10, 10, 10, 10, 10, 10, 10, 10];  % marker sizes

m_proj('lambert','lon',[-26 58.12],'lat',[-36 40]);  % African boundaries
m_line(aflon,aflat,'color','k','linewi',2);
%m_grid('linestyle','none','tickdir','out','linewidth',3);

m_line(-5, 34, 'marker','s', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','m');
m_line(-5, 32, 'marker','o', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','b');
m_line(34, -13, 'marker','o', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','c');
m_line(39.45, 8.46, 'marker','s', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','b'); % XJ has two centers
m_line(36, -2.6, 'marker','s', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','b'); % XJ has two centers
m_line(-8, 30.5, 'marker','^', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','r');
m_line(40, 11, 'marker','v', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','r');
m_line(13.6, -19, 'marker','o', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','r');
m_line(36, 0.3, 'marker','^', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','c');
m_line(31.6, -8, 'marker','d', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','m');

% create a legend for the markers
hh = [];
for is = 1:length(symbs)
    hh(is) = m_line(-90, 40, 'marker',symbs{is}, ...
        'markersize',10, 'color','k','linewi',1, 'linest','none','markerfacecolor',colors{is});
end

legend(hh, 'XB','XA','XK','XJ', '3D', 'ZF', '6A', '1C','ZP', 'Location', 'SouthEast', ...
    'fontsize', 10, 'Position', [0.13, 0.13, 0.1, 0.2]);

% set the size of the plot
x0=10;
y0=10;
width=600;
height=700;
set(gcf,'position',[x0,y0,width,height]);

% fig = gcf;
% saveFig('fig10_badNetwork_love.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);

%% Plot the outlier network center: Rayleigh
%%%% Networks have the most outliers in Love %%%%
% Plot the stations with different symbols
symbs = {'s', 'o','v','o', '^','^', 's', 'd', 'o'};  % marker types
colors = {'m', 'b','r', 'c','c','r','b','m','m'};
sze = [10, 10, 10, 10, 10, 10, 10, 10, 10];  % marker sizes

m_proj('lambert','lon',[-26 58.12],'lat',[-36 40]);  % African boundaries
m_line(aflon,aflat,'color','k','linewi',2);
%m_grid('linestyle','none','tickdir','out','linewidth',3);

m_line(-5, 34, 'marker','s', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','m');
m_line(-5, 32, 'marker','o', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','b');
m_line(40, 11, 'marker','v', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','r');
m_line(34, -13, 'marker','o', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','c');
m_line(36, 0.3, 'marker','^', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','c');
m_line(34.3, -10, 'marker','^', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','r'); % YQ
m_line(39.45, 8.46, 'marker','s', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','b'); % XJ has two centers
m_line(36, -2.6, 'marker','s', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','b'); % XJ has two centers
m_line(31.6, -8, 'marker','d', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','m');
m_line(40.3, 12.5, 'marker','o', 'color','k','linewi',1,...
        'linest','none','markersize',10,'markerfacecolor','m'); % 2H

% create a legend for the markers
hh = [];
for is = 1:length(symbs)
    hh(is) = m_line(-90, 40, 'marker',symbs{is}, ...
        'markersize',10, 'color','k','linewi',1, 'linest','none','markerfacecolor',colors{is});
end

legend(hh, 'XB','XA','ZF','XK', '1C', 'YQ', 'XJ', 'ZP','2H', 'Location', 'SouthEast', ...
    'fontsize', 10, 'Position', [0.13, 0.13, 0.1, 0.2]);

% set the size of the plot
x0=10;
y0=10;
width=600;
height=700;
set(gcf,'position',[x0,y0,width,height]);

% fig = gcf;
% saveFig('fig10_badNetwork_ray.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
%% Plot the plates of Africa
ax_avg=gca;

plotplates();
ax_avg.XLim=[-18 57];
ax_avg.YLim=[-36 40];

fig = gcf;
%saveFig('fig10_AfricanPlates.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
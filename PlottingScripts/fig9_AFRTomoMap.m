% Twicked from Yuri's plotting code 
% Plot Average Velocity map from Yuri's MC results
% Input data is generated from Prj5/4_Bin/Yuri_plotAfrica/AFRTomoMap_allMPI.m
% Nov. 30, 2021

load('/Users/sxue3/Documents/Figures/data/Fig9_maps/AFRTomoMap_WS.mat');

avgfig=figure();
avgfig.Units='normalized';
avgfig.OuterPosition(3)=0.4;
avgfig.OuterPosition(4)=0.85;
axesm('mercator','maplatlimit',[minlat maxlat],'maplonlimit',...
  [minlon maxlon])
% Axes and title
ax_avg=gca;
ax_avg.XLim=[minlon maxlon];
ax_avg.YLim=[minlat maxlat];
ax_avg.XLabel.String='Longitude (Degrees)';
ax_avg.XLabel.FontSize=17;
ax_avg.YLabel.String='Latitude (Degrees)';
ax_avg.YLabel.FontSize=17;
% ax_avg.Title.String={sprintf(...
%   'Average Velocity of %s Waves (%d s)',velType,velPd);...
%   sprintf('%d Iterations; Burnin %d',totaliter,burnin)};
ax_avg.XTick=10*ceil(minlon/10):10:10*floor(maxlon/10);
ax_avg.YTick=10*ceil(minlat/10):10:10*floor(maxlat/10);
ax_avg.FontSize=12;
hold on

% Colormap
clrmap=jet(2000);
clrmap=flip(clrmap);
colormap(ax_avg,clrmap)
cbar_avg=colorbar;
cbar_avg.Label.String='Phase Velocity (km/s)';
caxis([3.9 4.6]);
% if cbar_avg.Ticks(length(cbar_avg.Ticks)) ~= maxvel
%   cbar_avg.Ticks = [cbar_avg.Ticks maxvel];
% end
% if cbar_avg.Ticks(1) ~= minvel
%   cbar_avg.Ticks = [minvel cbar_avg.Ticks];
% end
cbar_avg.FontSize=12;
% Plot
avgplot=pcolor(longrid,latgrid,avgmap);
avgplot.EdgeAlpha=0;


% Plot Madgascar's Big Island
ctryline=polyshape((afcountries(448).X).',...
(afcountries(448).Y).');
madplot=plot(ctryline);
madplot.FaceAlpha=0;
madplot.LineWidth=1;
madplot.HandleVisibility='off';

% Plot coast of Africa and Eurasia
coast = shaperead('landareas.shp','UseGeoCoords',true,'RecordNumbers',2);
coastLons=(coast.Lon).';
coastLats=(coast.Lat).';
AfrEurCoast=polyshape(coastLons,coastLats);
coastplot=plot(AfrEurCoast);
coastplot.FaceAlpha=0;
coastplot.LineWidth=1;
coastplot.HandleVisibility='off';

% Plot African cratons
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

plot(lonCongo, latCongo, 'color', 'k', 'lineWidth', 2);
plot(lonKala, latKala, 'color', 'k', 'lineWidth', 2);
plot(lonSahara, latSahara, 'color', 'k', 'lineWidth', 2);
plot(lonTanza, latTanza, 'color', 'k', 'lineWidth', 2);
plot(lonWest, latWest, 'color', 'k', 'lineWidth', 2);
plot(lonZim, latZim, 'color', 'k', 'lineWidth', 2);

% Plot tectonic plate outlines
plotplates();
    
% Add label
text(-10, -30,'(a)','fontsize',30);

% Axes limits
ax_avg.XLim=[-20 55];
ax_avg.YLim=[-38 40];


%% Plot Standard Deviation Velocity Map
load('/Users/sxue3/Documents/Figures/data/Fig9_maps/AFRTomoMap_WS.mat');

sdevfig=figure();
sdevfig.Units='normalized';
sdevfig.OuterPosition(3)=0.4;
sdevfig.OuterPosition(4)=0.85;
axesm('mercator','maplatlimit',[minlat maxlat],'maplonlimit',...
  [minlon maxlon])

% Axes and title
ax_sdev=gca;
ax_sdev.XLim=[minlon maxlon];
ax_sdev.YLim=[minlat maxlat];
% ax_sdev.XLabel.String='Longitude (Degrees)';
% ax_sdev.XLabel.FontSize=13;
% ax_sdev.YLabel.String='Latitude (Degrees)';
ax_sdev.YLabel.FontSize=13;
% ax_sdev.Title.String={'Standard Deviation of Phase Velocity';...
%   sprintf('%s Waves (%d s)',velType,velPd);...
%   sprintf('%d Iterations; Burnin %d',totaliter,burnin)};
ax_sdev.XTick=10*ceil(minlon/10):10:10*floor(maxlon/10);
ax_sdev.YTick=10*ceil(minlat/10):10:10*floor(maxlat/10);
ax_sdev.FontSize=12;
hold on

% Colormap
clrmap_sdev=bone(2000);
colormap(ax_sdev,flipud(clrmap_sdev));
cbar_sdev=colorbar;
cbar_sdev.FontSize = 15;
cbar_sdev.Label.String='Uncertainty (km/s)';
cbar_sdev.Label.FontSize = 20;

caxis([minvel_sdev maxvel_sdev]);
if cbar_sdev.Ticks(length(cbar_sdev.Ticks)) ~= maxvel_sdev
  cbar_sdev.Ticks = [cbar_sdev.Ticks maxvel_sdev];
end
if cbar_sdev.Ticks(1) ~= minvel_sdev
  cbar_sdev.Ticks = [minvel_sdev cbar_sdev.Ticks];
end
%cbar_sdev.FontSize=12;

% Plot
sdevplot=pcolor(longrid,latgrid,sdevmap);
sdevplot.EdgeAlpha=0;  

% Plot African cratons
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

plot(lonCongo, latCongo, 'color', 'k', 'lineWidth', 2);
plot(lonKala, latKala, 'color', 'k', 'lineWidth', 2);
plot(lonSahara, latSahara, 'color', 'k', 'lineWidth', 2);
plot(lonTanza, latTanza, 'color', 'k', 'lineWidth', 2);
plot(lonWest, latWest, 'color', 'k', 'lineWidth', 2);
plot(lonZim, latZim, 'color', 'k', 'lineWidth', 2);

% Plot Madgascar's Big Island
ctryline=polyshape((afcountries(448).X).',...
(afcountries(448).Y).');
madplot=plot(ctryline);
madplot.FaceAlpha=0;
madplot.LineWidth=1;
madplot.HandleVisibility='off';

% Plot coast of Africa and Eurasia
coast = shaperead('landareas.shp','UseGeoCoords',true,'RecordNumbers',2);
coastLons=(coast.Lon).';
coastLats=(coast.Lat).';
AfrEurCoast=polyshape(coastLons,coastLats);
coastplot=plot(AfrEurCoast);
coastplot.FaceAlpha=0;
coastplot.LineWidth=2;
coastplot.HandleVisibility='off';

% Plot tectonic plate outlines
plotplates();

% Axes limits
ax_sdev.XLim=[-20 55];
ax_sdev.YLim=[-38 40];

% Add label
text(-10, -30,'(d)','fontsize',50);

% save the figure
% saveFig('fig9_AfrTomoMap_error_bone.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, gcf);

%% save the figure
% saveFig('fig9_AfrTomoMap.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, gcf);
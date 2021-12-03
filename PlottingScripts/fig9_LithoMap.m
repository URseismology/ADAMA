% Twicked from Yuri's plotting code 
% Plot Average Velocity map from Litho1.0 Map
% Input data is generated from Prj5/4_Bin/Yuri_plotAfrica/plotLITHOmap_Ma2014.m
% Nov. 30, 2021

%% Plot phase velocity map
lithofig=figure();
lithofig.Units='normalized';
if AFROnly==1
  lithofig.OuterPosition(3)=0.4;
  lithofig.OuterPosition(4)=0.85;
else
  lithofig.OuterPosition(3)=0.6;
  lithofig.OuterPosition(4)=0.65;
end
axesm('mercator','maplatlimit',[minlat maxlat],'maplonlimit',...
  [minlon maxlon])

% Axes and title
ax=gca;
if AFROnly==1
  ax.XLim=[minlon maxlon];
  ax.YLim=[minlat maxlat];
else
  ax.XLim=[-180 180];
  ax.YLim=[-90 90];
end
ax.XLabel.String='Longitude (Degrees)';
ax.XLabel.FontSize=13;
ax.YLabel.String='Latitude (Degrees)';
ax.YLabel.FontSize=13;
if wavetype=='L'
  wavestr='Love';
else
  wavestr='Rayleigh';
end

% Convert frequency in mHz to period
pdval=1/(freqval/1000);
% titlestr1=sprintf('%s Wave Phase Velocities (T = %.2fs)',wavestr,pdval);
% titlestr2='Ma et al. (2014) Dispersion Model (1 x 1 Degree)';
% ax.Title.String={titlestr1;titlestr2};
if AFROnly==1
  ax.XTick=10*ceil(minlon/10):10:10*floor(maxlon/10);
  ax.YTick=10*ceil(minlat/10):10:10*floor(maxlat/10);
else
  ax.XTick=-180:30:180;
  ax.YTick=-90:30:90;
end
ax.FontSize=12;
ax.Title.FontSize=12;
hold on

% Colormap
clrmap=jet(2000);
clrmap=flip(clrmap);
colormap(ax,clrmap)
cbar=colorbar;
cbar.Label.String='Phase Velocity (km/s)';
%caxis([minvel maxvel]);  % set the range of color bar based on velocity
caxis([3.9 4.6]);   % set the range of color bar manuallty
cbar.FontSize=12;

% Plot
lithoplot=pcolor(longrid,latgrid,velgrid);
lithoplot.EdgeAlpha=0;

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

% Plot tectonic plate outlines
plotplates();

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

% Add label
text(-10, -30,'(c)','fontsize',40);

% Axes limits
ax.XLim=[-20 55];
ax.YLim=[-38 40];

%% save the figure
saveFig('fig9_LithoMap.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, gcf);
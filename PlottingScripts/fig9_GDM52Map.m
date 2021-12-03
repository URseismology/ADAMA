% Twicked from Yuri's plotting code 
% Plot Average Velocity map from GDM52 Map
% Input data is generated from Prj5/4_Bin/Yuri_plotAfrica/plotGDM52.m
% Nov. 30, 2021

%% Plot phase velocity map
gdmfig=figure();
gdmfig.Units='normalized';
if AFROnly==1
  gdmfig.OuterPosition(3)=0.4;
  gdmfig.OuterPosition(4)=0.85;
else
  gdmfig.OuterPosition(3)=0.6;
  gdmfig.OuterPosition(4)=0.65;
end
axesm('mercator','maplatlimit',[minlat maxlat],'maplonlimit',...
  [minlon maxlon])
% Axes and title
ax_gdm=gca;
if AFROnly==1
  ax_gdm.XLim=[minlon maxlon];
  ax_gdm.YLim=[minlat maxlat];
else
  ax_gdm.XLim=[-180 180];
  ax_gdm.YLim=[-90 90];
end
ax_gdm.XLabel.String='Longitude (Degrees)';
ax_gdm.XLabel.FontSize=13;
ax_gdm.YLabel.String='Latitude (Degrees)';
ax_gdm.YLabel.FontSize=13;
if wavetype=='L'
  wavestr='Love';
else
  wavestr='Rayleigh';
end
% titlestr1=sprintf('%s Wave Phase Velocities (T = %ds)',wavestr,period);
% titlestr2='GDM52 Model (1 Degree x 1 Degree)';
% ax_gdm.Title.String={titlestr1;titlestr2};
if AFROnly==1
  ax_gdm.XTick=10*ceil(minlon/10):10:10*floor(maxlon/10);
  ax_gdm.YTick=10*ceil(minlat/10):10:10*floor(maxlat/10);
else
  ax_gdm.XTick=-180:30:180;
  ax_gdm.YTick=-90:30:90;
end
ax_gdm.FontSize=12;
ax_gdm.Title.FontSize=12;
hold on

% Colormap
clrmap=jet(2000);
clrmap=flip(clrmap);
colormap(ax_gdm,clrmap)
cbar_gdm=colorbar;
cbar_gdm.Label.String='Phase Velocity (km/s)';
caxis([3.9 4.6]);
cbar_gdm.FontSize=12;

% Plot
gdmplot=pcolor(longrid,latgrid,velgrid);
gdmplot.EdgeAlpha=0;

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
text(-10, -30,'(b)','fontsize',40);

% Axes limits
ax_gdm.XLim=[-20 55];
ax_gdm.YLim=[-38 40];

%% save the figure
saveFig('fig9_GDM52Map.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, gcf);
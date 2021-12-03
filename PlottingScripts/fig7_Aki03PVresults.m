% Plot the phase velocity dispersion curves in heatmap format 
% Four subplots: Rayleigh - Short, Rayleigh - Long, Love - Short, Love - Long
% Matrix for all four subplots are generated on Bluehive in Prj5/3_Src/fig7_getAkiData.m
% The code for fig7_getAkiData.m will also be uploaded to Google Drive
% Nov. 15, 2021 -- Siyu Xue

%% Plot the Short Distance (< 2000km) Love Phase Velocity
subplot(2,2,1)

% load in the data matrix
load('/Users/sxue3/Documents/Figures/data/AkiResults/hmap_LS_110K.mat');

% plot the heatmap matrix
imagesc(flip(log10(heatpv)));
text(520, 120,'(a)','fontsize',15, 'Color', 'white');
text(520, 15, 'r <= r_s','fontsize',12, 'Color', 'white');
text(2600, 15, 'C_l','fontsize',11, 'Color', 'white');
xline(432, 'r');

% plot the average phase velocity
newpv = flip(heatpv);
yvec = linspace(0,140,140);
xvec = linspace(0,7200,7200);
sumpv = yvec*newpv; % 1*7200 matrix, sum up the phase velocity for each x-axis value
pvsample = sum(newpv);
avgpv = sumpv./pvsample;
line(xvec(360:2880), avgpv(360:2880),'Color', 'white', 'LineWidth' , 2);

% set the ticks and labels
xticks([0,720, 1080, 1440, 1800, 2160, 2520, 2880, 3240, 3600, 3960, 4320, 4680, 5040]);
xticklabels(string([0,20,13.3,10,8,6.7,5.7,5,4.4,4,3.6,3.3,3.1,2.9]));
xlim([360,2882]);  % xlim([360,5041]); for F=0.35
xlabel('Period (s)');

yticks([0,10,20,30,40,50,60,70,80,90,100,110,120,130,139]);
yticklabels(string([7,nan,6,nan,5,nan,4,nan,3,nan,2,nan,1,nan,0]));
ylim([0,139]);
ylabel('Phase Velocity (km/s)');

grid on
set(gca,'XAxisLocation','top','LineWidth',1);
%title('Love Wave Phase Dispersion: 60 - 2000 km');
%colorbar;
%% Plot the Short Distance (< 2000km) Rayleigh Phase Velocity
subplot(2,2,2)

% load in the data matrix
load('/Users/sxue3/Documents/Figures/data/AkiResults/hmap_RS_110K.mat');

% plot the heatmap matrix
imagesc(flip(log10(heatpv)));
text(520, 120,'(b)','fontsize',15, 'Color', 'white');
text(2600, 15, 'C_r','fontsize',11, 'Color', 'white');
xline(504, 'r');

% plot the average phase velocity
newpv = flip(heatpv);
yvec = linspace(0,140,140);
xvec = linspace(0,7200,7200);
sumpv = yvec*newpv; % 1*7200 matrix, sum up the phase velocity for each x-axis value
pvsample = sum(newpv);
avgpv = sumpv./pvsample;
line(xvec(360:2880), avgpv(360:2880),'Color', 'white', 'LineWidth' , 2);

% set the ticks and labels
xticks([0,720, 1080, 1440, 1800, 2160, 2520, 2880, 3240, 3600, 3960, 4320, 4680, 5040]);
xticklabels(string([0,20,13.3,10,8,6.7,5.7,5,4.4,4,3.6,3.3,3.1,2.9]));
xlim([360,2882]);  % xlim([360,5041]); for F=0.35
xlabel('Period (s)');

yticks([0,10,20,30,40,50,60,70,80,90,100,110,120,130,140]);
%yticklabels(string([7,nan,6,nan,5,nan,4,nan,3,nan,2,nan,1,nan,0]));
yticklabels([]);
ylim([0,140]);
%ylabel('Phase Velocity (km/s)');

%title('Rayleigh Wave Phase Dispersion: 60 - 2000 km');
grid on;
set(gca,'XAxisLocation','top','LineWidth',1);
%colorbar;

%% Plot the Long Distance (> 2000km) Love Phase Velocity
subplot(2,2,3)

% load in the data matrix
load('/Users/sxue3/Documents/Figures/data/AkiResults/hmap_LL_110K.mat');

% plot the heatmap matrix
imagesc(flip(log10(heatpv)));
text(520, 120,'(c)','fontsize',15, 'Color', 'white');
text(520, 15, 'r > r_s','fontsize',12, 'Color', 'white');
xline(432, 'r');

% plot the average phase velocity
newpv = flip(heatpv);
yvec = linspace(0,140,140);
xvec = linspace(0,7200,7200);
sumpv = yvec*newpv; % 1*7200 matrix, sum up the phase velocity for each x-axis value
pvsample = sum(newpv);
avgpv = sumpv./pvsample;
line(xvec(360:2880), avgpv(360:2880),'Color', 'white', 'LineWidth' , 2);

% set the ticks and labels
xticks([0,720, 1080, 1440, 1800, 2160, 2520, 2880, 3240, 3600, 3960, 4320, 4680, 5040]);
xticklabels(string([0,50,75,100,125,150,175,200,225,250,275,300,325,350]));
xlim([360,2882]);  % xlim([360,5041]); for F=0.35
xlabel('Frequency (mHz)');

yticks([0,10,20,30,40,50,60,70,80,90,100,110,120,130,139]);
yticklabels(string([7,nan,6,nan,5,nan,4,nan,3,nan,2,nan,1,nan,0]));
ylim([0,139]);
ylabel('Phase Velocity (km/s)');

%title('Love Wave Phase Dispersion: > 2000 km');
grid on;
set(gca,'LineWidth',1) 
%colorbar;

%% Plot the Long Distance (> 2000km) Rayleigh Phase Velocity
subplot(2,2,4)

% load in the data matrix
load('/Users/sxue3/Documents/Figures/data/AkiResults/hmap_RL_110K.mat');

% plot the heatmap matrix
imagesc(flip(log10(heatpv)));
text(520, 120,'(d)','fontsize',15, 'Color', 'white');
xline(504, 'r');

% plot the average phase velocity
newpv = flip(heatpv);
yvec = linspace(0,140,140);
xvec = linspace(0,7200,7200);
sumpv = yvec*newpv; % 1*7200 matrix, sum up the phase velocity for each x-axis value
pvsample = sum(newpv);
avgpv = sumpv./pvsample;
line(xvec(360:2880), avgpv(360:2880),'Color', 'white', 'LineWidth' , 2);

% set the ticks and labels
xticks([0,720, 1080, 1440, 1800, 2160, 2520, 2880, 3240, 3600, 3960, 4320, 4680, 5040]);
xticklabels(string([0,50,75,100,125,150,175,200,225,250,275,300,325,350]));
xlim([360,2882]);  % xlim([360,5041]); for F=0.35
xlabel('Frequency (mHz)');

yticks([0,10,20,30,40,50,60,70,80,90,100,110,120,130,140]);
%yticklabels(string([7,nan,6,nan,5,nan,4,nan,3,nan,2,nan,1,nan,0]));
yticklabels([]);
ylim([0,140]);
%ylabel('Phase Velocity (km/s)');

%title('Rayleigh Wave Phase Dispersion: > 2000 km');
grid on;
set(gca,'LineWidth',1) 

% set the colorbar
c = colorbar;
c.Label.String = 'log_{10}(count)';
c.Position = [0.925 0.2 0.03 0.6];
c.Label.FontSize = 13;

% set the size of the plot
x0=10;
y0=10;
width=900;
height=500;
set(gcf,'position',[x0,y0,width,height]);
%% save the figure in PDF format
% fig = gcf;
% saveFig('fig7_AkiPhaseDispersion.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
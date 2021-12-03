% Plot the result of orientation test
% For a station pair, we rotate both stations to a certain degrees
% Nov. 30, 2021
% Siyu Xue

%% load data
mat = load('/Users/sxue3/Documents/Figures/data/Fig4/XD-RUNG_XD-MTAN_f.mat'); % the correct ccf
ccfT = mat.coh_sum;
cnm = mat.coh_num;

mat = load('/Users/sxue3/Documents/Figures/data/Fig4/XD-RUNG_XD-MTAN_n1.mat'); % sta1+270, sta2+0
ccfT1 = mat.coh_sum;
cnm1 = mat.coh_num;

mat = load('/Users/sxue3/Documents/Figures/data/Fig4/XD-RUNG_XD-MTAN_n2.mat'); % sta1+270, sta2+270
ccfT2 = mat.coh_sum;
cnm2 = mat.coh_num;

%% input the avarage phase velocity for short distance
% interpolate the phase velocity for the Bessel function
pvfreq = [0.025, 0.029, 0.033, 0.04, 0.05, 0.067, 0.086, 0.1, 0.125, 0.167, 0.2, 0.25, 0.333];
pvmed = [4.355, 4.276, 4.195, 4.113, 4.022, 3.920, 3.855, 3.809, 3.758, 3.705, 3.675, 3.64, 3.592]; 
dist = 109.5; % the distance between two stations in km

freq = 0.025:0.001:0.333;
pvinter = interp1(pvfreq, pvmed, freq);

plot(2*pi*pvfreq, pvmed, 'o', 2*pi*freq, pvinter, ':.');  % to check the interpolation

%% Plot Bessel function
Bessel0 = besselj(0,2*pi*freq*dist./pvinter);
Bessel2 = besselj(2,2*pi*freq*dist./pvinter);

RR = (Bessel0 + Bessel2)./2;
TT = (Bessel0 - Bessel2)./2;
%% Plot all waves to one figure
dt = 1;
T = length(ccfT1);
faxis = [0:(T-mod(T-1,2))/2 , -(T-mod(T,2))/2:-1]/dt/T;
ind = find(faxis>0);

clf
hold on

plot( 2*pi*freq, Bessel0, 'k-', 'LineWidth',1.5); % Bessel function of the first kind
plot( 2*pi*freq, TT, 'r-', 'LineWidth',1.5); % T-T orientation in theory
plot( 2*pi*freq, RR, 'b-', 'LineWidth',1.5); % R-R orientation in theory
plot(2*pi*faxis(ind),smooth(real(ccfT1(ind)/cnm1),100), 'color', [0 0.9 0], 'LineWidth',1.5); % R-T real data
xlim([0.15 1.5])

legend('J_{0}(\omegar/c_{L})', '[J_{0}(\omegar/c_{L})-J_{2}(\omegar/c_{L})]/2', ...
    '[J_{0}(\omegar/c_{L})+J_{2}(\omegar/c_{L})]/2', 'NCF_{RT}');
hold off
%title(sprintf('%s %s coherency T ,station distance: %f km',sta1,sta2,dist));
ylabel('Cross-spectra \rho(t)'); 
xlabel('Angular Frequency \omega')

% set the size of the plot
x0=10;
y0=10;
width=800;
height=300;
set(gcf,'position',[x0,y0,width,height]);

% save the fig to PDF
% fig = gcf;
% saveFig('fig4_Orientation_test.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
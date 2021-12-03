% Plot the stacked CCFs in Distance-Time in Love and Rayleigh
% Also a line plot indicates the counts in each distance range
% Data are processed using MATnoise a2 code
% Nov. 28, 2021

%% ---- Load data from the mat file ---- 
% load rayleigh data
DIST = load('/Users/sxue3/Documents/Figures/data/Fig5_110K/fig5_Ray_DIST.mat');
dist_ray = DIST.sta1sta2_dist_all;

CCF = load('/Users/sxue3/Documents/Figures/data/Fig5_110K/fig5_Ray_CCF.mat');
ccf_ray = CCF.ccf_all;

% load love data
DIST = load('/Users/sxue3/Documents/Figures/data/Fig5_110K/fig5_Love_DIST.mat');
dist_love = DIST.sta1sta2_dist_all;

CCF = load('/Users/sxue3/Documents/Figures/data/Fig5_110K/fig5_Love_CCF.mat');
ccf_love = CCF.ccf_all;

addpath('/Users/sxue3/Documents/Figures/Colormaps/');
clear DIST CCF

%% %----------- plot in color ------------%
%% (a) re-process the data
N= 14401;
xlims = [-3000 3000];

time = [0:N-1]-floor(N/2);
time = [time(time<0), time(time>=0)];

npairs_ray = length(ccf_ray);
npairs_love = length(ccf_love);
ntime = length(ccf_ray{1});
raylee_mat_afr = nan(npairs_ray, ntime);
love_mat_afr = nan(npairs_love, ntime);

% the rayleigh part
for ipairs = 1: npairs_ray
    
    if ~isempty(ccf_ray{ipairs})
        
        datvec = ccf_ray{ipairs};
        datvec = sqrt(datvec .* datvec);
        datvec_sm  = movavg(datvec', 'exponential', 50);

        maxdat = max( datvec_sm' );
        raylee_mat_afr(ipairs, :) = 1.* datvec_sm' ./ maxdat;
    end

end

% the love part
for ipairs = 1: npairs_love
    
    if ~isempty(ccf_love{ipairs})
        
        datvec = ccf_love{ipairs};
        datvec = sqrt(datvec .* datvec);
        datvec_sm  = movavg(datvec', 'exponential', 50);

        maxdat = max( datvec_sm' );
        love_mat_afr(ipairs, :) = 1.* datvec_sm' ./ maxdat;
    end
end

clear ccf_ray ccf_love

%% (b) stack
clc
% the rayleigh part
nfac = 100;
nstack = floor(npairs_ray ./ nfac);
maxdist = floor(max(dist_ray));
distvec_ray = linspace(60, maxdist, nstack);

stackRaylee = nan(nstack, ntime);
stackCount = zeros(1,nstack-1);
stackMid = zeros(1,nstack-1);
for istack = 1:nstack-1
    ld = distvec_ray(istack) ; rd = distvec_ray(istack+ 1) ;
    indstack = find((dist_ray >= ld) & (dist_ray <= rd));
    stackRaylee(istack,:) = nanmedian(raylee_mat_afr(indstack, :));
    stackCount(istack) = length(indstack);
    stackMid(istack) = (ld+rd)/2;
end

% the love part
nstack = floor(npairs_love ./ nfac);
maxdist = floor(max(dist_love));
distvec_love = linspace(60, maxdist, nstack);
stackLove = nan(nstack, ntime);

for istack = 1:nstack-1
    ld = distvec_love(istack) ; rd = distvec_love(istack+ 1) ;
    indstack = find((dist_love >= ld) & (dist_love <= rd));
    stackLove(istack,:) = nanmedian(love_mat_afr(indstack, :));
end
%% (c) plot
addpath('/Users/sxue3/Documents/Figures/Colormaps');

% change the xlimit and ylimit to fit the desired range
ylimit = [60 3500];
xlimit = [-1.5e3 1.5e3];

% Rayleigh plot
s1 = subplot(1,9,[1,2,3,4]);
imagesc(time, distvec_ray, stackRaylee);
colormap(inferno());
text(-1450, 150,'(a)','fontsize',20, 'Color', 'w');
%text(-3100, 300,'(a)','fontsize',20, 'Color', 'w');  % cordinations for 8000km plot
ah = colorbar('Position', [0.05, 0.22, 0.02, 0.6]);
ylabel(ah, 'Amplitude', 'fontsize', 15);
title('Rayleigh (ZZ)', 'FontSize', 15);
xlabel('Lag Time (s)', 'fontsize',15);
ylabel('Distance (km)', 'fontsize',15);
set(s1, 'Position', [0.12, 0.1, 0.33, 0.83]);

hold on
vel = 2.5;
vel2 = 3.8;

x1 = -5000:1:0;
x2 = 0:1:5000;

y1 = 60 - vel.*(x1);
y2 = 60 + vel.*(x2);
y3 = 60 - vel2.*(x1);
y4 = 60 + vel2.*(x2);


plot(x1,y1, 'w', 'LineWidth', 1);
plot(x2,y2, 'w', 'LineWidth', 1);
plot(x1,y3, 'w', 'LineWidth', 1);
plot(x2,y4, 'w', 'LineWidth', 1);


ylim(ylimit);
xlim(xlimit);
hold off

% Love plot
s2 = subplot(1,9,[5,6,7,8]);
imagesc(time, distvec_love, stackLove);
colormap(inferno());
text(-1450, 150,'(b)','fontsize',20, 'Color', 'w');
%text(-3100, 300,'(b)','fontsize',20, 'Color', 'w');  % cordinations for 8000km plot
title('Love (TT)', 'FontSize', 15);
xlabel('Lag Time (s)', 'fontsize',15);
set(s2, 'Position', [0.487, 0.1, 0.33, 0.83]);

hold on
vel = 2.5;
vel2 = 3.8;
x1 = -5000:1:0;
x2 = 0:1:5000;

y1 = 60 - vel.*(x1);
y2 = 60 + vel.*(x2);
y3 = 60 - vel2.*(x1);
y4 = 60 + vel2.*(x2);

plot(x1,y1, 'w', 'LineWidth', 1);
plot(x2,y2, 'w', 'LineWidth', 1);
plot(x1,y3, 'w', 'LineWidth', 1);
plot(x2,y4, 'w', 'LineWidth', 1);

ylim(ylimit);
xlim(xlimit);
hold off

% plot the line plot showing the wave count
s3 = subplot(1,9,9);
plot(stackMid,smooth(stackCount,5),'color',[0.9100 0.4100 0.1700],'LineWidth',4);
text(3400, 200,'(c)','fontsize',18);
%text(7700, 150,'(c)','fontsize',18);  % cordinations for 8000km plot
view(90, -90);
set(gca, 'xdir', 'reverse' )
title('No. Traces x 10^2', 'FontSize', 12);
xlim(ylimit);
yticks([0 100 200 300 400,500])
set(gca,'Yticklabel',[0,1,2,3,4,5]) 
set(gca,'xticklabel',[])
grid on
set(s3, 'Position', [0.85, 0.1, 0.04, 0.83]);

% set the size of the plot
x0=10;
y0=10;
width=1300;
height=600;
set(gcf,'position',[x0,y0,width,height]);

% save the fig to PDF
fig = gcf;
%saveFig('fig5_CCFintime_3500.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);

%% save the variables for future use
% filename = './fig5_variables.mat';
% save(filename, 'raylee_mat_afr', 'love_mat_afr', 'dist_ray', 'time', '-v7.3');

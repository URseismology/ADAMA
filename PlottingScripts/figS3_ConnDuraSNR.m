%%% Supliment Figure 3, to demonstrate the SNR quality over station pair connection durstion at different periods.
% Because Aki produces some strange file format, some of the data used here are input manually.
% --- Includes: 5 * 2 bar plots showing SNR v.s. duration for T = 5, 10, 13, 20, and 35 for both Rayleigh and Love

% Files needed:
    % ADAMA_ncfs_ZZ_fr.h5
    % ADAMA_ncfs_TT_fr.h5;
    % ADAMAraw_rs_ral.h5; 
    % ADAMAraw_rs_love.h5; 

% Siyu Xue; Feb. 8, 2022

%% Compute the SNR for all avaliable station pairs 
% Run this part of the code twice to get SNR for both Love and Rayleigh
% Next, rename the Rayleigh sinfo to rsinfo and Love sinfo to lsinfo for plotting.

WTYPE = 'L';  % 'R' for Rayleigh wave
CHAN = 'T';   % 'Z' for Rayleigh wave

addpath('/Users/sxue3/Documents/Figures/ADAMA_code/');  % add the readers for ADAMA

% read in the table that has station pair info
sinfo = readtable('/Users/sxue3/Documents/Figures/data/ADAMA_staconns.csv');
net1 = sinfo.net1;
sta1 = sinfo.sta1;
net2 = sinfo.net2;
sta2 = sinfo.sta2;

% add column to store SNR results for each station pair
sinfo.SNR5 = zeros(height(sinfo),1);
sinfo.SNR10 = zeros(height(sinfo),1);
sinfo.SNR13 = zeros(height(sinfo),1);
sinfo.SNR20 = zeros(height(sinfo),1);
sinfo.SNR35 = zeros(height(sinfo),1);

% loop through table and compute the SNR for all station pairs
for i = 1:height(sinfo)
    NET_STA1 = [net1{i} '.' sta1{i}];
    NET_STA2 = [net2{i} '.' sta2{i}];

    % read the ncf and fitted bessel function for the station pair
    [freq, rs, msgb] = read_ADAMA_raw(NET_STA1, NET_STA2, WTYPE, 'rs');
    [~, rncf, ~, msgp] = read_ADAMA_ncfs(NET_STA1, NET_STA2, CHAN);

    if all(rs == 0) || all(rncf == 0)
        % if no SNR data avaliable, skip the pair
        continue
    end

    % compute the SNR for 5 different periods
    for T = [5, 10, 13, 20, 35]
        %%% Taking the frequency interval from the time domain [T-1, T+1]
%         switch T
%             case 5
%                 fs = 2400; fe = 3600;
%             case 10
%                 fs = 1310; fe = 1600; 
%             case 13
%                 fs = 1029; fe = 1200;
%             case 20
%                 fs = 686; fe = 758;
%             case 35
%                 fs = 400; fe = 424;
%             otherwise
%                 disp('wrong period input');
%                 break
%         end

        %%% Taking the frequency interval from the frequency domain (f +- 50)
        switch T  
            case 5   % 2880
                fs = 2830; fe = 2930;
            case 10  % 1440
                fs = 1390; fe = 1490; 
            case 13  % 1107
                fs = 1057; fe = 1157;
            case 20  % 720
                fs = 670; fe = 770;
            case 35  % 410
                fs = 360; fe = 460;
            otherwise
                disp('wrong period input');
                break
        end
        signal = abs(rs([fs: fe]));
        ncf = abs(rncf([fs: fe]));
        %ncf = movavg(ncf, 'square',20);  % to smooth the ncf if needed
        %signal = movavg(signal, 'square',20);  % to smooth the fitted Bessel if needed

        noise = abs(signal - ncf);
        SNR = signal./noise;
        SNRavg = mean(SNR);

        colname = ['SNR', num2str(T)];
        sinfo.(colname)(i) = SNRavg;
    end
end

% Don't forget to change sinfo name for plotting!!!
%% Process Rayleigh SNR data

rcmat5 = zeros(5, 3);  % 5 categories in Duration * 3 categories in SNR
rcmat10 = zeros(5, 3);
rcmat13 = zeros(5, 3);
rcmat20 = zeros(5, 3);
rcmat35 = zeros(5, 3);

% loop through the station SNR table
i = 0; j = 0;
rows = height(rsinfo);
for r = 1:rows
    % if SNR == 0, skip the pair
    if rsinfo.SNR5(r) == 0
        continue
    end

    dura = rsinfo.x4hrWnd(r);
    dura = dura/(6*2-1);
    if dura > 730
        i = 5;
    elseif dura > 365
        i = 4;
    elseif dura > 180
        i = 3;
    elseif dura > 90
        i = 2;
    else
        i = 1;
    end

    if rsinfo.SNR5(r) < 5
        j = 1;
    elseif rsinfo.SNR5(r) <= 10
        j = 2;
    else
        j = 3;
    end    
    rcmat5(i,j) = rcmat5(i,j) + 1;

    if rsinfo.SNR10(r) < 5
        j = 1;
    elseif rsinfo.SNR10(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    rcmat10(i,j) = rcmat10(i,j) + 1;

    if rsinfo.SNR13(r) < 5
        j = 1;
    elseif rsinfo.SNR13(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    rcmat13(i,j) = rcmat13(i,j) + 1;

    if rsinfo.SNR20(r) < 5
        j = 1;
    elseif rsinfo.SNR20(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    rcmat20(i,j) = rcmat20(i,j) + 1;

    if rsinfo.SNR35(r) < 5
        j = 1;
    elseif rsinfo.SNR35(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    rcmat35(i,j) = rcmat35(i,j) + 1;
end

%% Process Love SNR data

lcmat5 = zeros(5, 3);  % 5 categories in Duration * 3 categories in SNR
lcmat10 = zeros(5, 3);
lcmat13 = zeros(5, 3);
lcmat20 = zeros(5, 3);
lcmat35 = zeros(5, 3);

% loop through the station SNR table
i = 0; j = 0;
rows = height(lsinfo);
for r = 1:rows
    % if SNR == 0, skip the pair
    if lsinfo.SNR5(r) == 0
        continue
    end

    dura = lsinfo.x4hrWnd(r);
    dura = dura/(6*2-1);
    if dura > 730
        i = 5;
    elseif dura > 365
        i = 4;
    elseif dura > 180
        i = 3;
    elseif dura > 90
        i = 2;
    else
        i = 1;
    end

    if lsinfo.SNR5(r) < 5
        j = 1;
    elseif lsinfo.SNR5(r) <= 10
        j = 2;
    else
        j = 3;
    end    
    lcmat5(i,j) = lcmat5(i,j) + 1;

    if lsinfo.SNR10(r) < 5
        j = 1;
    elseif lsinfo.SNR10(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    lcmat10(i,j) = lcmat10(i,j) + 1;

    if lsinfo.SNR13(r) < 5
        j = 1;
    elseif lsinfo.SNR13(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    lcmat13(i,j) = lcmat13(i,j) + 1;

    if lsinfo.SNR20(r) < 5
        j = 1;
    elseif lsinfo.SNR20(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    lcmat20(i,j) = lcmat20(i,j) + 1;

    if lsinfo.SNR35(r) < 5
        j = 1;
    elseif lsinfo.SNR35(r) <= 10
        j = 2;
    else
        j = 3;
    end   
    lcmat35(i,j) = lcmat35(i,j) + 1;
end
%%  Plot the SNR-included bar plot
fsize = 11;

%%%%%%% Plot Rayleigh SNR
%%%%   T = 5
subplot(5,2,1)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, rcmat5, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
text(0.25, 3.7*10^4,'T_{R} = 5','fontsize',16);
%xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);

%%%%   T = 10
subplot(5,2,3)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, rcmat10, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
text(0.25, 3.7*10^4,'T_{R} = 10','fontsize',16);
%xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);

%%%%   T = 13
subplot(5,2,5)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, rcmat13, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
%xlabel('Duration', 'FontSize', 14);
ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{R} = 13','fontsize',16);

%%%%   T = 20
subplot(5,2,7)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, rcmat20, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
%xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{R} = 20','fontsize',16);

%%%%   T = 35
subplot(5,2,9)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, rcmat35, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca, 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{R} = 35','fontsize',16);

%%%%%%% Plot Love SNR
%%%%   T = 5  
subplot(5,2,2)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, lcmat5, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
%xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{L} = 5','fontsize',16);
lgd = legend('< 5', '[5, 10]', '> 10');
lgd.Title.String = 'SNR';

%%%%   T = 10
subplot(5,2,4)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, lcmat10, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
%xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{L} = 10','fontsize',16);

%%%%   T = 13
subplot(5,2,6)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, lcmat13, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
%xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{L} = 13','fontsize',16);

%%%%   T = 20
subplot(5,2,8)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, lcmat20, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca,'Xticklabel',[], 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
%xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{L} = 20','fontsize',16);

%%%%   T = 35
subplot(5,2,10)
x = categorical({'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
x = reordercats(x,{'2-3 months', '3-6 months', '6-12 months', '1-2 years', '> 2 years'});
b1 = bar(x, lcmat35, 'stacked', 'LineWidth',1.5, 'FaceColor','flat');
b1(1).CData = [1 0.31 0.1];
b1(2).CData = [0.63 0.79 0.95];
b1(3).CData = [0.52 0.73 0.4];
set(gca, 'FontSize', fsize);
xtips = b1(3).XEndPoints;
ytips = b1(3).YEndPoints;
labels1 = ["8.7%", "23.9%", "35.3%", "28.0%", "4.2%"];  % just add '%' to labels1 
text(xtips,ytips,labels1,'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize', fsize)
ylim([0, 4.5] .* 10^4);
xlabel('Duration', 'FontSize', 14);
%ylabel('Connection Count', 'FontSize', 14);
text(0.25, 3.7*10^4,'T_{L} = 35','fontsize',16);

% set the size of the plot
x0=10;
y0=10;
width=1000;
height=1500;
set(gcf,'position',[x0,y0,width,height]);

% save the plot in PDF format
fig = gcf;
saveFig('figS3_ConnDuraSNR.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
%% Figure 3 in the paper, to demonstrates AkiEstimate results. 
% Because Aki produces some strange file format, some of the data used here are input manually.
% --- Includes:
    %-1. good station Rayleigh zero-crossing & Rayleigh Bessel fitting
    %-2. bad station Love zero-crossing & Love Bessel fitting
    %-3. reference plot(Aki01) for both station pairs
    
% Siyu Xue; July 22, 2021
%% Read in data for XD-RUNG_XD-MTAN
%  subplot(1): zero-crossing plot (Ray01):
PairList = '/Users/sxue3/Documents/Figures/data/Fig3/fig3_ray1.csv'; % data from ResultOf02 (Med2)
A = readtable(PairList);
freq = A{:,'Var1'};
raysignal = A{:,'Var2'};
rayb = A{:,'Var3'};

% data from Initial Phase (Med1)
raya = 0.21545315180732377;
rpeaks = [0.03847,0.06944,0.09631,0.30283];
rtroughs = [0.05298,0.08277,0.10992,0.13707,0.16839,0.19631,0.25616,0.28672,0.34796];
rzeros = [0.02842235490830198,0.06221199951268816,0.08904994938516128,0.10204085137948331,...
    0.11647110684144751,0.14613717180965938,0.17553901536486605,0.20604029263668083,0.2648235108143142,...
    0.29545161223273836,0.35584198085742363];

% subplot(2): station reference plot
PairList = '/Users/sxue3/Documents/Figures/data/Fig3/fig3_rayref.csv';
B = readtable(PairList);
rayrefx = B{:,'Var1'};
rayrefy = B{:,'Var2'};
rayep = B{:,'Var3'};

rayf = [0.02842235490830198,0.03847,0.05298,0.06221199951268816,0.06944,0.08277,0.08904994938516128,...
    0.09631,0.10204085137948331,0.10992,0.11647110684144751,0.13707,0.14613717180965938,0.16839,...
    0.17553901536486605,0.19631,0.20604029263668083,0.25616,0.2648235108143142,0.28672,0.29545161223273836,...
    0.30283,0.34796,0.35584198085742363];
rayc = [3.560309146674738,3.7916746679766127,3.6009392929800765,3.648183805527086,3.6037777912869244,...
    3.4748464446299674,3.407397722017473,3.3949777908665695,3.3263869619972075,3.339456009364551,...
    3.307105376417914,3.262996190093124,3.2985362971141496,3.2954685385091573,3.2879028327990527,...
    3.261696476022423,3.2979447837826674,3.268892768871407,3.2837019399195704,3.2786479651923073,...
    3.292518074926269,3.2918278353766737,3.294275330040037,3.297667175100279];

% subplot(3): Bessel fitting; data from ResultOf03 (Med3)
PairList = '/Users/sxue3/Documents/Figures/data/Fig3/XD.pred-rayleigh';
C = readtable(PairList,'FileType','text');
raypredx = C{:,'Var1'};
raypv = C{:,'Var3'};
raypredy = C{:,'Var6'};
rindices = find(raypv > 0);

PairList = '/Users/sxue3/Documents/Figures/data/Fig3/dispersion_XD-RUNG_XD-MTAN.rayleigh';
D = readtable(PairList,'FileType','text');
rncf = D{3:end,'Var4'};

% read in the uncertainty bounds (saved on Bluehive when running the uncentainty python code)
dat = readmatrix('/Users/sxue3/Documents/Figures/data/Fig3/XD_rayleigh_uncert.csv');
uncf = dat(:,1).';  % frequency 
runcub = dat(:,2).';  % rayleigh uncertainty upper bound
runclb = dat(:,3).';  % rayleigh uncertainty lower bound
%% Read in data for XA-SA53_XA-SA58
%  subplot(1): zero-crossing plot (Ray01):
PairList = '/Users/sxue3/Documents/Figures/data/Fig3/fig3_lov1.csv';
A = readtable(PairList);
lovsignal = A{:,'Var2'};
lovb = A{:,'Var3'};

lova = 0.04946772061563283;
lpeaks = [0.03791,0.0559,0.07638,0.09826,0.11728,0.17172,0.18804,0.20575,0.26088,0.27734,0.3522,0.37122];
ltroughs = [0.02923,0.04632,0.06597,0.0877,0.12638,0.14478,0.17929,0.21561,0.23457,0.28727,0.30671,0.32477,0.34227,0.3797,0.39671];
lzeros = [0.02561711534576073,0.033766273923643376,0.04142277595655553,0.05158534699679148,...
    0.07187962497324578,0.0943528898915029,0.10493808158282757,0.12220911608794116,0.13251326344392017,...
    0.1506809695569531,0.1745549934971024,0.18342730447284214,0.19285493971335635,0.21140055520608442,...
    0.21959413770810962,0.2397496330811952,0.2646800495397432,0.2915971991393275,0.3115711395130617,...
    0.3292211182634382,0.3466600809286873,0.3566652042187448,0.37583896080073487,0.38445248293365164];

% subplot(2): station reference plot
PairList = '/Users/sxue3/Documents/Figures/data/Fig3/fig3_lovref.csv';
B = readtable(PairList);
lovrefx = B{:,'Var1'};
lovrefy = B{:,'Var2'};
lovep = B{:,'Var3'};

lovf = [0.02561711534576073,0.02923,0.033766273923643376,0.03791,0.04142277595655553,0.04632,...
    0.05158534699679148,0.0559,0.06597,0.07187962497324578,0.07638,0.0877,0.0943528898915029,...
    0.09826,0.10493808158282757,0.11728,0.12220911608794116,0.12638,0.13251326344392017,0.14478,...
    0.1506809695569531,0.17172,0.1745549934971024,0.17929,0.18342730447284214,0.18804,0.19285493971335635,...
    0.20575,0.21140055520608442,0.21561,0.21959413770810962,0.23457,0.2397496330811952,0.26088,...
    0.2646800495397432,0.27734,0.28727,0.2915971991393275,0.30671,0.3115711395130617,0.32477,...
    0.3292211182634382,0.34227,0.3466600809286873,0.3522,0.3566652042187448,0.37122,0.37583896080073487,...
    0.3797,0.38445248293365164,0.39671];
lovc = [4.095649749849698,3.9751691042895256,3.961946781869793,3.936633862874709,3.8383848823091156,...
    3.890936653265719,3.9494666884094394,3.942759707887094,4.0102222141053865,4.083744667238546,...
    4.079567679491214,4.17730989208546,4.261266764953004,4.2233388141730694,4.298560447572944,...
    4.2173902492533735,4.220904701708374,4.201481150913731,4.243981859230381,4.181726604054377,...
    4.2130986691954835,4.144322142559257,4.0997871713764,4.1021904052622125,4.090051106794389,...
    4.089887916927276,4.093038622997649,4.072762735813556,4.092230104758404,4.084344992187575,...
    4.071864591906084,4.091503406104756,4.100325864328562,4.067138482387561,4.054363222406124,...
    4.037858676990728,4.048583488728519,4.0446422294313695,4.0625354302132966,4.065599238205064,...
    4.05766336139931,4.055582921979677,4.046694317449644,4.044165946814235,4.055226723804277,...
    4.053510682270953,4.061828820166595,4.061783983346583,4.053893092068033,4.055355994389486,...
    4.039632031785313];

% subplot(3): Bessel fitting
PairList = '/Users/sxue3/Documents/Figures/data/Fig3/XA.pred-love';
C = readtable(PairList,'FileType','text');
lovpredx = C{:,'Var1'};
lovpv = C{:,'Var3'};

lovpredy = C{:,'Var6'};
lindices = find(lovpv > 0);

PairList = '/Users/sxue3/Documents/Figures/data/Fig3/dispersion_XA-SA53_XA-SA58.love';
D = readtable(PairList,'FileType','text');
lncf = D{3:end,'Var4'};

% read in the uncertanty bounds
dat = readmatrix('/Users/sxue3/Documents/Figures/data/Fig3/XA_love_uncert.csv');
luncub = dat(:,2).';  % love uncertainty upper bound
lunclb = dat(:,3).';  % love uncertainty lower bound
%% Plot 

% clear command window and figures
clc
clf

% --- XD-RUNG_XD-MTAN ---

% get the y vlaue for peaks, troughs, and zeros
pa = ones(1,length(rpeaks));
rpa = raya .* pa;
ta = ones(1,length(rtroughs));
rta = -raya .* ta;
za = ones(1,length(rzeros));
rza = 0 .* za;

subplot(3,2,1)
hold on
yline(0);
p1=plot(freq, rayb, 'Color', [100 100 100]/225, 'LineWidth', 1.5); % plot the Besseul function
p2=plot(freq, smooth(raysignal,10), 'b', 'LineWidth', 1.5); % plot the signal
scatter(rpeaks,rpa,40,'r', 'filled'); % plot the peaks
scatter(rtroughs,rta,40,'b', 'filled'); % plot the troughs
scatter(rzeros,rza,40,'k', 'filled'); % plot the zeros
ylim([-0.25, 0.25]);

% set the title and labels
title("Rayleigh: XD-RUNG_XD-MTAN",'Interpreter','none');
label_y = ylabel('Cross-spectra \rho(t)'); 
label_y.Position(1) =-0.08;
label_y.Position(2) =-0.37;
text(0.46, -0.2,'(a)','fontsize',15);
hold off

subplot(3,2,5)
hold on
x2 = [uncf(uncf<0.34), fliplr(uncf(uncf<0.34))];
inBetween = [runcub(uncf<0.34), fliplr(runclb(uncf<0.34))];
fill(x2, inBetween, [0.85 0.85 0.85]);

p4=plot(rayrefx, rayrefy,'k:', 'LineWidth', 1.5); % plot the Rayleigh reference curve
p5=plot(rayf(rayf<0.343),rayc(rayf<0.343),'-', 'LineWidth', 1.5, 'color', [0 0.7 0]); % plot the zero-crossing predicted Rayleigh 

p7x_temp = freq(rindices);
p7y_temp = raypv(rindices)./1000;
p7=plot(p7x_temp(p7x_temp<0.34),p7y_temp(p7x_temp<0.34),'r-', 'LineWidth', 1.5); % plot the predicted phase velocity
legend([p4 p5 p7], {'reference','initial prediction','final prediction'});
ylim([3,4.5]);
xlim([0,0.5]);

% set the title and labels
xlabel('Frequency (Hz)');
label_h = ylabel('Phase velocity (km/s)'); 
label_h.Position(1) =-0.08;
grid on
text(0.3, 4.35,'(e)','fontsize',15);
hold off

subplot(3,2,3)
hold on

plot(freq, smooth(rncf,10), 'b', 'LineWidth', 1.5); % plot the Rayleigh NCF curve
p3=plot(raypredx(rindices), smooth(raypredy(rindices),10), 'r', 'LineWidth', 1.5); % plot the fitted Bessel function

legend([p1 p2 p3],{'reference Bessel' , 'NCF signal', 'Bessel fitting'});
ylim([-0.25, 0.25]);
text(0.46, -0.2,'(c)','fontsize',15);
hold off

% --- Plot XA-SA53_XA-SA58 ---

% get the y vlaue for peaks, troughs, and zeros
pa = ones(1,length(lpeaks));
lpa = lova .* pa;
ta = ones(1,length(ltroughs));
lta = -lova .* ta;
za = ones(1,length(lzeros));
lza = 0 .* za;

subplot(3,2,2)
hold on
yline(0);
plot(freq, lovb, 'Color', [100 100 100]/225, 'LineWidth', 1.5); % plot the Besseul function
plot(freq, smooth(lovsignal,10), 'b', 'LineWidth', 1.5); % plot the signal
scatter(lpeaks,lpa,40,'r', 'filled'); % plot the peaks
scatter(ltroughs,lta,40,'b', 'filled'); % plot the troughs
scatter(lzeros,lza,40,'k', 'filled'); % plot the zeros
ylim([-0.1, 0.1]);
title("Love: XA-SA53_XA-SA58",'Interpreter','none');
text(0.46, -0.08,'(b)','fontsize',15);
hold off

subplot(3,2,6)
hold on
x2 = [uncf(uncf<0.34), fliplr(uncf(uncf<0.34))];
inBetween = [luncub(uncf<0.34), fliplr(lunclb(uncf<0.34))];
fill(x2, inBetween, [0.85 0.85 0.85]);

plot(lovrefx, lovrefy,'k:', 'LineWidth', 1.5); % plot the Love reference curve
plot(lovf(lovf<0.343),lovc(lovf<0.343),'-', 'LineWidth', 1.5, 'color', [0 0.7 0]); % plot the zero-crossing predicted Love 

tempx = freq(lindices);
tempy = lovpv(lindices)./1000;
plot(tempx(tempx<0.34),tempy(tempx<0.34),'r-', 'LineWidth', 1.5); % plot the predicted phase velocity

ylim([3.5,5]);
xlabel('Frequency (Hz)');
grid on
text(0.465, 4.85,'(f^ )','fontsize',15);
hold off

subplot(3,2,4)
hold on
plot(freq, smooth(lncf,10),'b', 'LineWidth', 1.5); % plot the Love NCF curve
plot(lovpredx(lindices), smooth(lovpredy(lindices),10), 'r', 'LineWidth', 1.5); % plot the fitted Bessel function
ylim([-0.1, 0.1]);
text(0.46, -0.08,'(d)','fontsize',15);
hold off

% set the size of the plot
x0=10;
y0=10;
width=1100;
height=650;
set(gcf,'position',[x0,y0,width,height]);

% save the fig to PDF
fig = gcf;
saveFig('fig3_AkiResults.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
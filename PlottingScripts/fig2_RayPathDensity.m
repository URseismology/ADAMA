% Plotting the three subplots of ray path density in Figure 2
% Usually generate the plotting materials (Part 1, 5, 6, 7) on Bluehive.
% The code can be found at /Prj5_HarnomicRFTraces/4_Bin/figs4PlotDrO/Fig_RayPathDensity.m

% The plotting code starts at line 212. 
% Input file: African cratons (because the ones on Bluehive are not correct)

%% 1. path file 
mntDir = '/gpfs/fs2/scratch/tolugboj_lab/';
addpath([mntDir 'Prj5_HarnomicRFTraces/4_Bin/figs4PlotDrO/spheretri-master/']);
addpath([mntDir 'Prj5_HarnomicRFTraces/4_Bin/figs4PlotDrO/m_map/']);
GEODIR = [mntDir 'Prj3_AfricaLithosphere/2_Data/geoData/'];
inPathFile = ['/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/prepross_connection_0.csv'];

% load africa coverage  ...
fname = [mntDir 'Prj3_AfricaLithosphere/2_Data/geoData/AfricaCoast.mat'];

dat = readtable(inPathFile);
lon1 = dat.lon1;
lat1 = dat.lat1;
lon2 = dat.lon2;
lat2 = dat.lat2;
index = 1:length(lon1);

ploc = [index' lon1 lat1 lon2 lat2];

%2.  discretization of final raycoverage
delP = 0.25;   % path delta
%3. discretization of final map
delDeg = 0.25;  % map delta

%4. re-weigh based on max distance
maxDeg = 10; %maximum distance to rescale -- 30 degrees



afcoast = load(fname);
aflon = wrapTo180(afcoast.XY(:,1));
aflat = afcoast.XY(:,2);

S1 = shaperead([GEODIR 'Africa_SHP/Africa.shp']);

% load africa cratons
if 1
    AfricaCratons = load([GEODIR 'AfricaCratons_Lekic.mat']);
    longWafr = wrapTo180( AfricaCratons.AfricaCratons.Wafr(:,1) );
    latWafr = AfricaCratons.AfricaCratons.Wafr(:,2);
    longCongoA = wrapTo180( AfricaCratons.AfricaCratons.CongoA(:,1) );
    latCongoA = AfricaCratons.AfricaCratons.CongoA(:,2);
    longCongoB = wrapTo180( AfricaCratons.AfricaCratons.CongoB(:,1) );
    latCongoB = AfricaCratons.AfricaCratons.CongoB(:,2);
    longSAfr = wrapTo180( AfricaCratons.AfricaCratons.SAfr(:,1) );
    latSAfr = AfricaCratons.AfricaCratons.SAfr(:,2);
end

% --Siyu updated dataset
% allSta = [mntDir 'Prj5_HarnomicRFTraces/2_Data/all_sta_in_notin_Africa.csv'];
% midSta = [mntDir 'Prj5_HarnomicRFTraces/4_Bin/mid_conn_sta.csv'];
% highSta = [mntDir 'Prj5_HarnomicRFTraces/4_Bin/high_conn_sta.csv'];
% 
% allStalocs = readtable(allSta);
% midStalocs = readtable(midSta);
% highStalocs = readtable(highSta);

%% 5. confirm face triangulation

figure
clc
[vMat, fMat] = spheretri(30000);
patch('Vertices',vMat,'Faces',fMat,'FaceColor','g','EdgeColor','k');

% quick check on points for first face..
face = vMat(fMat(1,:), :);
[flon, flat, fr] = cart2sph(face(:,1), face(:,2), face(:,3) );
flat = rad2deg(flat);
flon = rad2deg(flon);

s1 = m_idist(flon(1), flat(1), flon(2), flat(2));
s2 = m_idist(flon(1), flat(1), flon(3), flat(3));
s3 = m_idist(flon(2), flat(2), flon(3), flat(3));

% distance in degrees between vertices on particular face..
fd = [km2deg(s1./1e3), km2deg(s2./1e3), km2deg(s3./1e3)];


[llon, llat, rr] = cart2sph(vMat(:,1), vMat(:,2), vMat(:,3) );
llat = rad2deg(llat); llon = rad2deg(llon);



%% 6. select faces located exclusively in africa

% africa bounds
aflatq = [-36, 40];
aflonq =  [-18 57]; 

%
clc
nFaces = length(fMat);
faceInAfrica = false(nFaces, 1);  % about 82k points for 1deg resl.

for iFace = 1 : nFaces
    face = vMat(fMat(iFace,:), :);
    [flon, flat, ~] = cart2sph(face(:,1), face(:,2), face(:,3) );
    flat = rad2deg(flat); mflat = mean(flat);
    flon = rad2deg(flon); mflon = mean(flon);
    
    IN = inpolygon(flon,flat,aflon,aflat);
    numIN = floor(sum(IN));
    
    % if all 3 vertices are inside africa then face is in!
    if numIN == 3
        faceInAfrica(iFace) = true;
    end
    
end

afMat = fMat(faceInAfrica,:);

% unique vertices
afVI = unique(afMat(:)); % unique index of all faces in africa ...
afVMat = vMat(afVI,:);

[allon, allat, ~] = cart2sph(afVMat(:,1), afVMat(:,2), afVMat(:,3) );
allat = rad2deg(allat); allon = rad2deg(allon);
      
%% 7 KERNEL: on what face do points lie ?
clc

% set the distance threshold for the three plots
Degshort = 10;
Degmid = 20;
Deglong = 30;

nFaces = length(afMat);
cntInFace = zeros(nFaces, 1);  % about 82k points for 1deg resl.

faceHit = 0;
faceInd = [];   % index of face with 
faceCnt = [];

faceStat = zeros(nFaces, 3); % center coordinate of all faces, with count of points on face
faceStatL = zeros(nFaces, 3); % number of faces with path greater than the shord, mid, long threshold

[totPath, ~] = size(ploc) ;

for iK = 1:totPath
    ln = [ploc(iK,2); ploc(iK,4)];
    lt = [ploc(iK,3); ploc(iK,5)];
    
    [s, az12, az21] = m_idist(ln(1), lt(1), ln(2), lt(2));
    sdel = km2deg(s./1e3);
    
    % points on path at 0.25 degree resolution
    nlegs = floor(sdel/delP);
    [lnp, ltp] = gcwaypts(ln(1), lt(1),ln(2), lt(2), nlegs);
    
    siK = num2str(iK); snK = num2str(totPath);
    nFace4Path = 0;
    
    for iFace = 1 : nFaces
        face = vMat(fMat(iFace,:), :);
        [flon, flat, fr] = cart2sph(face(:,1), face(:,2), face(:,3) );
        flat = rad2deg(flat); mflat = mean(flat);
        flon = rad2deg(flon); mflon = mean(flon);
        
        
        %  see if path is in face ..
        IN = inpolygon(lnp,ltp,flon,flat);
        numIN = floor(sum(IN));
        
        %[iK iFace]
        if numIN >= 1
            %faceStat(iFace, 3) = [mflon, mflat, numIN];
            siFace = num2str(iFace);
            faceStat(iFace, 3) = faceStat(iFace, 3) + 1;

            % Dr. O's old version of the plots     
%             if sdel <= maxDeg
%                 faceStatL(iFace,1) = faceStatL(iFace,1) + 1;
%             else
%                 faceStatL(iFace,2) = faceStatL(iFace,2) + 1;
%             end

            if sdel <= Degshort
                faceStatL(iFace,1) = faceStatL(iFace,1) + 1;
            elseif sdel <= Degmid
                faceStatL(iFace,2) = faceStatL(iFace,2) + 1;
            elseif sdel <= Deglong
                faceStatL(iFace,3) = faceStatL(iFace,3) + 1;
            end

            nFace4Path = nFace4Path + 1;
            %disp(['found ' siK ' at ' siFace]);
            %break;
        end   
        
    end
    
    sFace4Path = num2str(nFace4Path);
    snFaces = num2str(nFaces);
    
    disp(['completed, path ' siK ' of ' snK ' matched ' sFace4Path ...
        ' of ' snFaces]);
    
    
end


%% save the workspace
%save('entire_workspace');
%load('entire_workspace');

%% visualize ray coverage ...
figure
clf

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

disp([ num2str(faceHit) ' of ' num2str(nFaces)])

% visualize count ... 
sz = .24;
lond = -180:sz:180;
latd = -90:sz:90;

[dlon, dlat] = meshgrid(lond, latd);

for iV = 1:1
    if iV == 1
        %subplot(311)
        midcount = faceStatL(:,2) + faceStatL(:,1);
        midcount(midcount==0)=NaN;
        
        F = scatteredInterpolant(faceStat(:,1), faceStat(:,2), ...
             log(midcount), 'natural' );
        
        %ytit = '% Path < 2*10^3 km (~20 ^{\circ})';
        ytit = 'log(Path < 2*10^3 km)';
        crange = [0.4 1.2];
        fval = F(dlon, dlat) ;
        text(-0.6, -0.53,'(a)','fontsize',70);
    elseif iV == 2
        %subplot(312)
        longcount = faceStatL(:,3);
        longcount(longcount==0)=NaN;
        
        F = scatteredInterpolant(faceStat(:,1), faceStat(:,2), ...
             log(longcount) , 'natural' );
         
        %ytit = '% Path < 3*10^3 km (~30 ^{\circ})';
        ytit = 'log(2*10^3 km < Path < 3*10^3 km)';
        crange = [0.4 1.2];
        fval = F(dlon, dlat) ;
        text(-0.6, -0.53,'(b)','fontsize',70);
    else
        %subplot(313)
        test = faceStat(:,3);
        
        test(test==0)=NaN;
        
        F = scatteredInterpolant(faceStat(:,1), faceStat(:,2), ...
             log(test) , 'natural' );
         
        %ytit = '% Path < 3*10^3 km (~30 ^{\circ})';
        ytit = 'log(All Raypaths)';
        crange = [0.4 1.2];
        fval = F(dlon, dlat) ;
        text(-0.6, -0.53,'(c)','fontsize',70);
    end
%     
    % -- plot face count
    %latlim = [-36 40]; lonlim = [-18 57]; % the whole Africa
    latlim = [-36 40];
    lonlim = [-18 57];
    m_proj('miller', 'lat',latlim, 'lon', lonlim );
    m_grid('xtick',[],'ytick',[],'linestyle','-');
    hold on
    m_pcolor(dlon, dlat, fval)
    cmap = 'default'; colormap(cmap);
    y = colorbar('southoutside', 'fontsize', 30);
    caxis([0, 7]);
    ylabel(y, ytit, 'fontsize', 35);

    m_coast();

    % plot countries and cratons
    for iCntry = 1:length(S1)
        m_line([S1(iCntry).X], [S1(iCntry).Y], 'color', [0.5 0.5 .5], 'linewi',2);  % states ...
    end
        

    % plot cratons
    m_line(lonCongo, latCongo, 'color','k','linewi',2);
    m_line(lonKala, latKala, 'color','k','linewi',2);
    m_line(lonSahara, latSahara, 'color','k','linewi',2);
    m_line(lonTanza, latTanza, 'color','k','linewi',2);
    m_line(lonWest, latWest, 'color','k','linewi',2);
    m_line(lonZim, latZim, 'color','k','linewi',2);

    m_line(aflon,aflat,'color','k','linewi',2);
    
    
   % plot XD-RUNG,MTAN and XA-SA53,SA58 on the map (c)
%    m_line(XDBox(:,2), XDBox(:,1),'color','c','linewi',7);
%    m_line(XABox(:,2), XABox(:,1),'color','r','linewi',7);
end

% set the size of the plot
x0=10;
y0=10;
width=700;
height=1050;
set(gcf,'position',[x0,y0,width,height]);

% save the plot in PDF format
fig = gcf;
saveFig('fig2_RayPathDensity_a.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);

%% Plot the histgram of Paths v.s. Distance
% dat = readtable('/Users/sxue3/Documents/Figures/data/prepross_connection_0.csv');
% dists = dat.distance_km;
% 
% histogram(dists, [0:250:9500]);
% xlim([-100,9500]);
% text(9000, 6600,'(e)','fontsize',15);
% 
% ylabel('Count');
% xlabel('Distance (km)');
% 
% x0=10;
% y0=10;
% width=700;
% height=120;
% set(gcf,'position',[x0,y0,width,height])

% save the plot in PDF format
% fig = gcf;
% saveFig('fig1_ConnectionHist.pdf', '/Users/sxue3/Documents/Figures/fig/', 1, fig);
function plotplates(lonlimflag)
% 
% Function to plot tectonic plate boundaries on a map, using the points
% provided by Bird (2003), and references therein
% 
% INPUT
% lonlimflag : Limits of longitude values, in degrees
%              Default: 0 [-180 180]
%                       1 [0 360]
% 
% Last Modified: July 29, 2021 by Yuri Tamama
% 
% References : Bird, P. (2003) An updated digital model of plate 
%              boundaries. Geochemistry, Geophysics, Geosystems, 4. 
%              doi:10.1029/2001GC000252 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set default variable
if ~exist('lonlimflag','var')
  lonlimflag=0;
end


% Load plates file
platefile='/Users/sxue3/Documents/Figures/data/Fig9_maps/PB2002_boundaries.dig.txt';
fid=fopen(platefile);

% Examine the file line by line
[status,cmdout]=system(sprintf('cat %s | wc -l',platefile));
% Number of lines
numlines=str2double(cmdout);
% 
segmentlon=[];
segmentlat=[];

for l=1:numlines
  linestr=fgetl(fid);
  
  % Is coordinate
  if strcmp(linestr(1),' ')
    if ~isempty(segmentlon)
      lonpt_temp=linestr(2:find(linestr==',')-1);
      lonpt_temp=str2double(lonpt_temp);
      if lonlimflag==1
        if lonpt_temp<0
          lonpt_temp=lonpt_temp+360;
        end
      end
      % Need to break apart line segment
      if abs(lonpt_temp-segmentlon(end))>100
        plotcase=3;
      else
        plotcase=1;
      end
    else
      plotcase=1;
    end
  % End of segment
  elseif strcmp(linestr(1:3),'***') && ~isempty(segmentlon)
    plotcase=2;
  % Segment name
  else
    continue;
  end
  
  switch plotcase
    % Add coordinate to segment
    case 1
      % Convert lon, lat to double
      lonpt=linestr(2:find(linestr==',')-1);
      lonpt=str2double(lonpt);
      if lonlimflag==1
        if lonpt<0
          lonpt=lonpt+360;
        end
      end
      %
      latpt=linestr(find(linestr==',')+1:end);
      latpt=str2double(latpt);
      % Add to array
      segmentlon=[segmentlon; lonpt];
      segmentlat=[segmentlat; latpt];
      
    % End of segment, so plot!
    case 2
      % Plot the segment
      plateplot=plot(segmentlon,segmentlat);
      plateplot.LineWidth=2.5;
      plateplot.HandleVisibility='off';
      plateplot.Color=[0 0 0];
      hold on
    
      % Reset segment
      segmentlon=[];
      segmentlat=[];
      
    % Need to break apart line segment
    case 3
      % First, plot what we have
      plateplot=plot(segmentlon,segmentlat);
      plateplot.LineWidth=2.5;
      plateplot.HandleVisibility='off';
      plateplot.Color=[0 0 0];
      hold on
      
      % Start new segment with current point
      lonpt=linestr(2:find(linestr==',')-1);
      lonpt=str2double(lonpt);
      if lonlimflag==1
        if lonpt<0
          lonpt=lonpt+360;
        end
      end
      %
      latpt=linestr(find(linestr==',')+1:end);
      latpt=str2double(latpt);
    
      % Add to array
      segmentlon=[lonpt];
      segmentlat=[latpt];
  end

end  
  
% Close file
fclose(fid);

  
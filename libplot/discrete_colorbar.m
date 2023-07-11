function [c,cmap] = discretecolorbar(varargin)
%DISCRETECOLORBAR colorbar with discrete spacing
% 
% 
% See also

%% parse inputs

[data, nvals, location, setticks] = parseinputs(mfilename, varargin{:});

%% main

% make the colorbar
c = colorbar(location);

if isnan(nvals)
   nvals = 10;
end

% if no data or nvals are passed in, use default labels
if isnan(data)
   cmap = colormap(parula(10));
   return
end

% otherwise set the colormap to nvals
cmap = colormap(parula(nvals));

if setticks == false
   c.TickLength = 0.0;
   
else

   % build the new tick marks and labels
   minval = min(data);
   maxval = max(data);
   newticks = linspace(minval,maxval,nvals+1);
   halftick = diff(newticks(1:2))/2;
   newticks = newticks+halftick;
   newticks = newticks(1:end-1);

   % NEW: try to round intelligently
   prec = getnumprecision(newticks);
   for n = 1:numel(newticks)
      newticks(n) = round(newticks(n),prec(n));
   end

   % apply the new settings
   c.Ticks = newticks;
   c.TickLength = 0.0;
   c.TickLabels = {num2str(newticks(:))};
   
end

% parse inputs
function [data, nvals, location, setticks] = parseinputs(funcname, varargin)
p = inputParser;
p.FunctionName = funcname;
p.addOptional( 'data', nan, @isnumeric);
p.addParameter('nvals', nan, @isnumeric);
p.addParameter('location', 'eastoutside', @ischar);
p.addParameter('setticks', false, @islogical);
p.parse(varargin{:});

data = p.Results.data;
nvals = p.Results.nvals;
location = p.Results.location;
setticks = p.Results.setticks;

% former syntax is saved at the end (in case this breaks antyhing)

% % I think the key is adjusting c.Limits
% 
% % otherwise, try to determine even tick marks and/or adjust nvals
% 
% minmaxvals = [10^(floor(log10(minval))) 10^(ceil(log10(maxval)))];
% newticks = floor(linspace(minmaxvals(1),minmaxvals(2),nvals));
% 
% c.Limits = minmaxvals;
% c.Ticks = 

% % not sure if its worth the time to figure out how to get the best tick
% % marks for a log plot and then adjust the tickmarks
% % modify the colorbar
% if strcmp(flog,'log') == true
%    set(gca,'ColorScale','log');
% end
% 
% if strcmp(flog,'log') == true
%    cticklabels = c.TickLabels;
%    %newcticklabels = cticklabels(1:5:end);
%    %tickinds = 1:5:length(cticklabels);
%    tickinds = 1:length(cticklabels);
%    for n = 1:length(cticklabels)
%       if any(n == tickinds)
%          cticknum = str2double(cticklabels{n});
%          cticklabel = exp(cticknum);
%          
%          exp(floor(exp(cticknum)))
%          
%          if cticknum
%             
%             cticklabel = roundn(exp(str2num(cticklabels{n})),0);
%             %cticklabel = roundn(10^str2num(cticklabels{n}),0);
%             c.TickLabels{n} = cticklabel;
%          else
%             c.TickLabels{n} = '';
%          end
%       end
%       
%       else
%          c.TickLabels = {num2str(newticks(:))};
%    end
%    
% end
%    
%    
%    



% % former syntax (in case this breaks antyhing)
% % function [c,cmap] = discrete_colorbar(data,nvals,location,varargin)
% % narginchk(3,4)
% 
% % first make the colorbar
% c = colorbar(location);
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % NOTE: need to fix the nargin, what I want is to be able to pass in a
% % colormap e.g. 'parula' and maybe the ticklabels, but i also want to
% % be able to set 'log'
% 
% % % if 3 args are given, make the ticklabels from nvals
% if nargin == 3
%    cmap = colormap(parula(nvals));
%    ticklabels = {num2str((1:nvals)')};
% elseif nargin == 4
%    cmap = colormap(parula(nvals));
%    ticklabels = {num2str((1:nvals)')};
%    flog = varargin{1};
% elseif nargin == 5
%    % if 5 args are given, assume the fourth one is the name of a colormap,
%    % and I guess the second one is custom tick labels
%    cmap = colormap(varargin{1}(nvals));
%    ticklabels = varargin{2};
% end
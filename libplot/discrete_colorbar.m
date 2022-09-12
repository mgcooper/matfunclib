function c = discrete_colorbar(data,nvals,location,varargin)
    
    % input checks
    narginchk(3,4)
    
    % first make the colorbar
    c       = colorbar(location);
    
    % NOTE: need to fix the nargin, what I want is to be able to pass in a
    % colormap e.g. 'parula' and maybe the ticklabels, but i also want to
    % be able to set 'log'
    
    % if 3 args are given, make the ticklabels from nvals
    if nargin==3
        C = colormap(parula(nvals));
        ticklabels = {num2str([1:nvals]')};
    elseif nargin==4
        C = colormap(parula(nvals));
        ticklabels = {num2str([1:nvals]')};
        flog = varargin{1};
    elseif nargin==5
    % if 5 args are given, assume the fourth one is the name of a colormap,
    % and I guess the second one is custom tick labels
        C = colormap(varargin{1}(nvals));
        ticklabels = varargin{2};
    end
    
    % build the new tick marks and labels
    minval      = min(data);
    maxval      = max(data);
    newticks    = linspace(minval,maxval,nvals+1);
    halftick    = diff(newticks(1:2))/2;
    newticks    = newticks+halftick;
    newticks    = newticks(1:end-1);
    
    % apply the new settings
    c.Ticks         = newticks;
    c.TickLength    = 0.0;
    c.TickLabels    = {num2str(newticks(:))};
    
% % not sure if its worth the time to figure out how to gett he best tick
% % marks for a log plot and then adjust the tickmarks
%     % modify the colorbar
%     if strcmp(flog,'log') == true
%         set(gca,'ColorScale','log');
%     end
%     
%     if strcmp(flog,'log') == true
%         cticklabels         =   c.TickLabels;
%        %newcticklabels      =   cticklabels(1:5:end);
%        %tickinds            =   1:5:length(cticklabels);
%         tickinds            =   1:length(cticklabels);
%         for n = 1:length(cticklabels)
%             if any(n==tickinds)
%                 cticknum        = str2double(cticklabels{n});
%                 cticklabel      =   exp(cticknum);
%                 
%                 exp(floor(exp(cticknum)))
%                 
%                 if cticknum
%                 
%                 cticklabel      =   roundn(exp(str2num(cticklabels{n})),0);
%                %cticklabel      =   roundn(10^str2num(cticklabels{n}),0);
%                 c.TickLabels{n} =   cticklabel;
%             else
%                 c.TickLabels{n}     =   '';
%             end
%         end
%         
%     else
%         c.TickLabels    = {num2str(newticks(:))};
%     end
    
    
    
    
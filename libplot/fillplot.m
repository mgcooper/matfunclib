function [ h ] = fillplot( x,y_low,y_high,fillC,dir,varargin )
%FILLPLOT Creates a fill plot, data must be columnwise
% 
%   h = fillplot(x,y_low,y_high,fillC,dir,varargin )

X = [x,fliplr(x)];
Y = [y_low,fliplr(y_high)];

if strcmp(dir,'x')
    h = fill(X,Y,fillC,varargin{:});
elseif strcmp(dir,'y')
    h = fill(Y,X,fillC,varargin{:});
end

% first take care of nans

% if any(isnan(x)) || any(isnan(y_low)) || any(isnan(y_low))
%     
%     x       =   [nan 1 7 nan nan 9 5 nan 3 5 nan nan];
%     y_low   =   [1 4 3 6 4 2 4 5 4 2 1 8];
%     y_high  =   y_low + 2;
%       
%     % if there are naninds in one variable, make them nan in the other
%     nanindsx        =   find(isnan(x));
%     nanindsL        =   find(isnan(y_low));
%     nanindsH        =   find(isnan(y_high));
%     naninds         =   unique([nanindsx nanindsL nanindsH]);        
%     x(naninds)      =   nan;
%     y_low(naninds)  =   nan;
%     y_high(naninds) =   nan;
%     
%     % now proceed
%     nanindsx        =   isnan(x);
%     nanindsL        =   isnan(y_low);
%     nanindsH        =   isnan(y_high);
% 
% %     gapsx           =   [0 diff(nanindsx)];
% %     gapsL           =   [0 diff(nanindsL)];
% %     gapsH           =   [0 diff(nanindsH)];
%     
%     gapsx           =   diff(nanindsx);
%     gapsL           =   diff(nanindsL);
%     gapsH           =   diff(nanindsH);
% %     
% %     if isnan(x(end))
% %         gapsx       =   [gapsx -1];
% %         gapsL       =   [gapsL -1];
% %         gapsH       =   [gapsH -1];
% %     else
% %         gapsx       =   [gapsx 0];
% %         gapsL       =   [gapsL 0];
% %         gapsH       =   [gapsH 0];
% %     end
%         
% %     ngapsx          =   sum(gapsx(gapsx==-1));
% %     ngapsL          =   sum(gapsL(gapsL==-1));
% %     ngapsH          =   sum(gapsx(gapsx==-1));
%     starts          =   unique([find(~isnan(x),1,'first') ...
%                                             find(gapsx == -1) + 1]);
%     ends            =   find(gapsx == 1);
%     
%     % make the first part of the plot
%     x1              =   x(starts(1):ends(1));
%     yL1             =   y_low(starts(1):ends(1));
%     yH1             =   y_high(starts(1):ends(1));
%     
%     X1              =   [x1,fliplr(x1)];
%     Y1              =   [yL1,fliplr(yH1)]
%     
%     if strcmp(dir,'x')
%         p   =   fill(X,Y,fillC,varargin{:});
%     elseif strcmp(dir,'y')
%         p   =   fill(YL1,X1,fillC,varargin{:});
%     end
%     
%     for n = 1:length(starts)
%         X           =   x(1:starts(n));
%     end % GIVING UP HERE - found boundedline.m
%     
%     
% 
% X   =   [x,fliplr(x)];
% Y   =   [y_low,fliplr(y_high)];
% 
% else
%     
%     if strcmp(dir,'x')
%         p   =   fill(X,Y,fillC,varargin{:});
%     elseif strcmp(dir,'y')
%         p   =   fill(Y,X,fillC,varargin{:});
%     end
% 
% end


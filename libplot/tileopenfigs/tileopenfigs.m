function h = tileopenfigs(varargin)
%TILEOPENFIGS tiles open figures or an array of figures into a tilelayout

%------------------------------------------------------------------------------
p=inputParser;
p.FunctionName=mfilename;
p.addOptional('figarray',get(groot,'Children'),@(x)isa(x,'matlab.ui.Figure'));
p.addParameter('deletefigs',true,@(x)islogical(x));
parse(p,varargin{:});
figarray = p.Results.figarray;
deletefigs = p.Results.deletefigs;
%------------------------------------------------------------------------------ 

% see fex getfignum if for some reason it is helpful to get the list of open but
% unused figures

newfig = figure;
tcl = tiledlayout(newfig,'flow');

numfigs = numel(figarray);

for n = 1:numfigs

% % %  reactivate for og method
   figure(figarray(n));
   
   %    axlist = findobj(gcf,'Type','Axes');
   %    axlist = findall(gcf,'Type','Axes');
   
   ax=gca;
   ax.Parent=tcl;
   ax.Layout.Tile=n;


% % these are my attempts to copy all the info over
%    oldfig = figure(figarray(n));
%    
%    oldaxes = findobj(oldfig,'Type','axes');
%    oldleg  = findobj(oldfig,'Type','Legend');
% 
%    newaxes(n).Parent = tcl;
%    newaxes.Layout.Tile=n;
%    newaxes = copyobj([oldaxes;oldleg],newfig);
%   
%    
% % % % % % % % % % % % % % % % % % % 
%    oldfig = figure(figarray(n));
%    
%    % get mainfig size
%    %newFig         =  figure('Position',oldfig.Position);
%    oldaxes  =  findobj(oldfig,'Type','axes');
%    oldleg      =  findobj(oldfig,'Type','Legend');
%    %oldText        =  findall(oldfig,'Type','Annotation');
%    
%    for n = 1:numel(newaxes)
%       newaxes(n).Parent = tcl;
%    end
%    newaxes.Layout.Tile=n;
%    newaxes  =  copyobj([oldaxes;oldleg],newfig);
% %    newOldFigAxes  =  copyobj([oldFigAxesObj;oldLegend;oldText],newfig);
%   
%    newaxes.Layout.Tile=n;
   
end

if deletefigs 
   delete(figarray);
end

% % this was copied into the loop above then got modified into the current mess
% so i copied it again here in case its a better starting point
% for n = 1:numfigs
%    
%    oldfig = figure(figarray(n));
%    
%    % get mainfig size
%    newFig         =  figure('Position',oldfig.Position);
%    oldFigAxesObj  =  findobj(oldfig,'Type','axes');
%    oldLegend      =  findobj(oldfig,'Type','Legend');
%    oldText        =  findall(oldfig,'Type','Annotation');
%    
%    newOldFigAxes.Parent = tcl;
%    newOldFigAxes  =  copyobj([oldFigAxesObj;oldLegend;oldText],newFig);
%   
%    newOldFigAxes.Layout.Tile=n;
%    
% end

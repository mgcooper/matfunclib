function h = tileopenfigs(varargin)
%TILEOPENFIGS tiles open figures or an array of figures into a tilelayout

%------------------------------------------------------------------------------
p=inputParser;
p.FunctionName='tileopenfigs';
p.addOptional('figarray',get(groot,'Children'),@(x)isa(x,'matlab.ui.Figure'));
p.addParameter('deletefigs',true,@(x)islogical(x));
parse(p,varargin{:});
figarray = p.Results.figarray;
deletefigs = p.Results.deletefigs;
%------------------------------------------------------------------------------ 

newfig = figure;
tcl = tiledlayout(newfig,'flow');

numfigs = numel(figarray);

for n = 1:numfigs
   
   figure(figarray(n));
   
   %    axlist = findobj(gcf,'Type','Axes');
   %    axlist = findall(gcf,'Type','Axes');
   
   ax=gca;
   ax.Parent=tcl;
   ax.Layout.Tile=n;
   
end

if deletefigs 
   delete(figarray);
end

figure(5)
function [xticks,yticks,lonlabels,latlabels] = getlatlonticks(ax,proj)

xticks  = get(ax,'xtick');
yticks  = get(ax,'ytick');
xlims   = get(ax,'xlim');
ylims   = get(ax,'ylim');
yticks  = yticks(1:3:end);
xticks  = xticks(1:3:end);
[latticks,~] = projinv(proj,xlims(2)*ones(size(yticks)),yticks);
[~,lonticks] = projinv(proj,xticks,ylims(2)*ones(size(xticks)));
lonlabels = cell(length(lonticks),1);
latlabels = cell(length(latticks),1);
for n = 1:length(lonticks)
   lonlabels{n} = [printf(lonticks(n),1) '^oW'];
end
for n = 1:length(latticks)
   latlabels{n} = [printf(latticks(n),1) '^oN'];
end


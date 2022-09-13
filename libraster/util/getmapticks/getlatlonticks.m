function [xticks,yticks,lonlabels,latlabels] = getlatlonticks(ax,proj)
    
    xticks  = get(ax,'xtick');
    yticks  = get(ax,'ytick');
    xlims   = get(ax,'xlim');
    ylims   = get(ax,'ylim');
    yticks  = yticks(1:3:end);
    xticks  = xticks(1:3:end);
    [latticks,~] = projinv(proj,xlims(2)*ones(size(yticks)),yticks);
    [~,lonticks] = projinv(proj,xticks,ylims(2)*ones(size(xticks)));
    for i = 1:length(lonticks)
        lonlabels{i} = [printf(lonticks(i),1) '^oW'];
    end
    for i = 1:length(latticks)
        latlabels{i} = [printf(latticks(i),1) '^oN'];
    end
    
end


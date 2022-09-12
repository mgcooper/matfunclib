function fpos = figposition(f)
    if nargin==0
        fpos = get(gcf,'Position');
    else
        fpos = get(f,'Position');
    end
end


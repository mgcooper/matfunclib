function cms = cfs2cms(cfs)
   % Converts cubic feet per second to cubic meters per second
   cms = cfs.*(ft2m(1).^3);
end

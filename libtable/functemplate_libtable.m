function tbls = functemplate_libtable(tbls)
   %F Description
   %
   %  tbls = f(tbls)
   %
   % See also:

   [tbls, wasstruct, names] = parseinputs(tbls);

   tbls = cellmap(@(tbl) processOneTable(tbl), tbls);

   if wasstruct
      tbls = cell2struct(tbls, names, 1);
   else
      tbls = tbls{:};
   end
end

function tbl = processOneTable(tbl)

end

%%
function [tbls, wasstruct, names] = parseinputs(tbls)
   wasstruct = isstruct(tbls);
   if wasstruct
      [names, tbls] = deal(string(fieldnames(tbls)), struct2cell(tbls));
   elseif istabular(tbls)
      tbls = {tbls};
   end
end

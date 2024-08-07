function tbls = functemplate_libtable(tbls)
   %F Description
   %
   %  tbls = f(tbls)
   %
   % See also:

   % Prepare inputs.
   [tbls, wastabular, wasstruct, names] = parseinputs(tbls);

   % Process each table.
   tbls = cellmap(@(tbl) processOneTable(tbl), tbls);

   % Prepare outputs.
   tbls = parseoutputs(tbls, wastabular, wasstruct, names);
end

%%
function tbl = processOneTable(tbl)

end

%%
function [tbls, wastabular, wasstruct, names] = parseinputs(tbls)

   names = string.empty;
   wasstruct = isstruct(tbls);
   wastabular = istabular(tbls);

   if iscell(tbls)
      assert(all(cellfun(@istabular, Merra)))

   elseif wasstruct
      [tbls, names] = deal(struct2cell(tbls), string(fieldnames(tbls)));

   elseif wastabular
      tbls = {tbls};
   end
end

function tbls = parseoutputs(tbls, wastabular, wasstruct, names)

   if wasstruct
      tbls = cell2struct(tbls, names, 1);

   elseif wastabular
      tbls = tbls{:};
   end
end

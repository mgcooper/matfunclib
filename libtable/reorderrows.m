function tbl = reorderrows(tbl, orderednames, kwargs)
   %REORDERROWS Order table rows by an ordered list, using RowNames or column.
   %
   %  reorderrows(tbl, orderednames, byvariable=varname)
   %
   % See also: reordervars

   arguments
      tbl tabular
      orderednames (:, 1) string
      kwargs.byvariable (1, :) string = string.empty
   end

   if ~isempty(kwargs.byvariable)
      names = tbl.(kwargs.byvariable);
   else
      names = tbl.Properties.RowNames;
   end
   assert(~isempty(names))

   [~, order] = ismember(orderednames, names, 'rows');
   tbl = tbl(order, :);

   if numel(order) ~= numel(names)
      wid = ['custom:' mfilename ':missingNamesRemoved'];
      msg = 'Rows which are not members of ordered names were removed.';
      warning(wid, msg);
   end

   % % This works as-is if the table has rownames, because then the name-based
   % % indexing at the end works. If ordering by a variable and there are names
   % % missing from orderednames, then this needs an additional method to append
   % % the rows matching the missing names to the end, or interleave them somehow.
   % % For now, the function does not support "keepMissingVars".
   % keepPositionNames = names(~ismember(names, orderednames)) ;
   % movePositionNames = names( ismember(names, orderednames)) ;
   % [~, newPositions] = ismember(orderednames, movePositionNames);
   % movePositionNames = movePositionNames(newPositions);
   %
   % % At this time, non-common vars are moved to the end, not interleaved.
   % if kwargs.keepMissingVars
   %    movePositionNames = [movePositionNames, keepPositionNames];
   % end
   % % Reorder the vars.
   % tbl = tbl([movePositionNames, keepPositionNames], :);
end

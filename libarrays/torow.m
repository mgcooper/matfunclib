function Row = torow(Array)
   %TOROW Convert array to row.
   %
   %  Row = torow(Array)
   %
   % See also: tocolumn, vec

   Row = transpose(tocolumn(Array));
end

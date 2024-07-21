function mustBePolygonOrFile(P)
   %mustBePolygonOrFile validates input as a polygon or filename
   %
   % Input can be a polyshape, Nx2 numeric matrix, or cell array containing
   % one or more valid polygon representations, or a filename which is meant to
   % contain valid polygon geometry. No validation is performed on the contents
   % of the file.
   %
   % Example use in argument block validation:
   %
   % arguments
   %     P { mustBePolygonOrFile(P) };
   % end
   %
   % See also: ispolygon mustBePolygon

   if ~ispolygon(P) && ~isfile(P)
      eid = ['custom:validators:' mfilename];
      msg = 'Value must be a polyshape, Nx2 numeric matrix, or valid cell array, or a valid filename.';
      throwAsCaller(MException(eid, msg));
   end
end

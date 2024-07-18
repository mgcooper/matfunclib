function mustBePolygon(P)
   % mustBePolygon validates input as a polygon representation
   %
   % Input can be a polyshape, Nx2 numeric matrix, or cell array containing
   % one or more valid polygon representations.
   %
   % Example use in argument block validation:
   %
   % arguments
   %     P { mustBePolygon(P) };
   % end
   %
   % See also: ispolygon

   if ~ispolygon(P)
      eid = ['custom:validators:' mfilename];
      msg = 'Value must be a polyshape, Nx2 numeric matrix, or valid cell array.';
      throwAsCaller(MException(eid, msg));
   end
end

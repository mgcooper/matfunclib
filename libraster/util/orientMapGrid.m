function [X, Y] = orientMapGrid(X, Y, varargin)
   %ORIENTMAPGRID Orient grid coordinates N-S, W-E or as specified.
   %
   % [X, Y] = orientMapGrid(X, Y) orients the input grid X and Y to be W-E
   % for X and N-S for Y by default.
   %
   % [X, Y] = orientMapGrid(X, Y, orientation) allows specifying the desired
   % orientation as a string: 'WE_NS', 'EW_SN', 'WE_SN', or 'EW_NS'.
   %
   % Example:
   %   [Xnew, Ynew] = orientMapGrid(X, Y, 'EW_SN');
   %
   % Note:
   %   The orientation is specified as a combination of X and Y directions:
   %   'WE' or 'EW' for X, and 'NS' or 'SN' for Y.
   %
   % Matt Cooper, 11-Mar-2023, https://github.com/mgcooper
   %
   % See also: prepareMapGrid, mapGridInfo, mapGridCellSize

   % If scalar coordinates or an unstructured grid were passed in, return
   if isscalar(X) && isscalar(Y) || ...
         ismember(mapGridFormat(X, Y), {'irregular', 'coordinates'})
      return
   end

   % Check for warning off input
   [opt, args, nargs] = parseoptarg(varargin, 'off');

   % Check for custom orientation input
   if nargs > 0
      orientation = varargin{1};
   else
      orientation = 'WE_NS';
   end

   % If X, Y are vectors, orient them so X is a row and Y is a column
   if iscolumn(X); X = X'; end
   if isrow(Y); Y = Y'; end

   % Check and adjust X orientation
   msg = [];
   switch orientation(1:2)
      case 'WE'
         if X(1,1) ~= min(X(:)) || X(1,2) < X(1,1)
            X = fliplr(X);
            msg = ['Input argument 1, X, was re-oriented W-E. ' ...
               'Ensure the data referenced by X is oriented W-E.'];
         end
      case 'EW'
         if X(1,1) ~= max(X(:)) || X(1,2) > X(1,1)
            X = fliplr(X);
            msg = ['Input argument 1, X, was re-oriented E-W. ' ...
               'Ensure the data referenced by X is oriented E-W.'];
         end
   end

   % Check and adjust Y orientation
   switch orientation(4:5)
      case 'NS'
         if Y(1,1) ~= max(Y(:)) || Y(1,1) < Y(2,1)
            Y = flipud(Y);
            msg = ['Input argument 2, Y, was re-oriented N-S. ' ...
               'Ensure the data referenced by Y is oriented N-S.'];
         end
      case 'SN'
         if Y(1,1) ~= min(Y(:)) || Y(1,1) > Y(2,1)
            Y = flipud(Y);
            msg = ['Input argument 2, Y, was re-oriented S-N. ' ...
               'Ensure the data referenced by Y is oriented S-N.'];
         end
   end

   if ~strcmp(opt, 'off') && ~isempty(msg)
      disp(msg)
   end
end

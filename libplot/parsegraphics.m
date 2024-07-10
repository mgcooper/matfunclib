function [H, args, nargs, wasfigure, wasimage] = parsegraphics(varargin)
   %PARSEGRAPHICS Parse graphics handles / objects from varargin-type cell array
   %
   %   [H,ARGS,NARGS,WASFIGURE,WASIMAGE] = PARSEGRAPHICS(ARG1,ARG2,...) looks
   %   for a Figure or Axes provided in the input arguments. If one of the
   %   arguments is a figure or axes handle, it is removed from the list in ARGS
   %   and the count in NARGS. PARSEGRAPHICS first checks the arguments for
   %   Name, Value pairs with the name 'Parent'. If a graphics object is found
   %   following the last occurence of 'Parent', then all 'Parent', Value pairs
   %   are removed from the list in ARGS and the count in NARGS. PARSEGRAPHICS
   %   then checks if any remaining arguments are graphics objects. If a
   %   graphics object is found, either on its own or following the last
   %   occurance of 'Parent', it is returned in AX. WASFIGURE is set to true if
   %   a Figure handle is detected, and false otherwise. WASIMAGE is set true
   %   if an Image handle is detected, and false otherwise (this check is
   %   ignored if the Image Processing Toolbox is not available). Double handles
   %   to graphics objects are converted to graphics objects. If the handle is
   %   determined to be a handle to a deleted graphics object, an error is
   %   thrown.
   %
   %   Note: Unlike the undocumented Mathworks function `axescheck`, the
   %   `parsegraphics` function does not require that the graphics object be
   %   supplied as the first argument.
   %
   %
   % See also: axescheck isaxis isfig isimage isgraphicslike
   % matlab.graphics.chart.internal.inputparsingutils
   %
   % This function is based on the undocumented function axescheck
   % (Copyright 1984-2020 The MathWorks, Inc.)
   %
   % NOTE: isaxis and isfig are octave-compatible, but the Parent,handle checks
   % in the "findparent" subfunction may not be.

   % TODO:
   %  Add "asfigure", "PreferParent", and/or "KeepArgs" logical name-value
   %  arguments. One or more of these, possibly in combination, would solve the
   %  problem of parsing multiple graphics objects from the same varargin,
   %  and/or the problem of determining whether to return the
   %  'Parent',<graphics> pair or the lone <graphics> handle if both are found.

   % Assign defaults.
   [H, args, nargs, wasfigure, wasimage] = deal( ...
      [], varargin, nargin, false, false);

   % Early exit if no args were supplied.
   if nargs == 0
      return
   end

   % Search for a 'Parent',<graphics> pair first.
   [index, found] = findparent(args{:});
   if any(found)
      % Check for a graphics-like object paired with 'Parent'. A graphics-like
      % object is either a scalar numeric handle, or any size array of actual
      % graphics objects. If the argument is passed using the 'Parent' P/V
      % pair, this will catch any graphics handle(s), and not just Axes.
      if (nargs >= index+1) && isgraphicslike(args{index+1})
         found(index+1) = true;
         H = handle(args{index+1});
         args = args(~found);
         nargs = nargs-2;
         wasimage = isimage(H);
         wasfigure = isfig(H);
      end
   end

   % Check for either a scalar numeric Figure or Axes handle, or any size array
   % of Axes or Figures. 'isgraphics' will catch numeric graphics handles, but
   % will not catch deleted graphics handles, so we need to check for both.

   % Search for an Axes or Figure
   if nargs > 0
      [index, found] = findgraphics(args{:});

      if any(found)

         if ~isempty(H)
            wid = 'parsegraphics:MultipleGraphicsFound';
            msg = ['More than one graphics object was found. The object ' ...
               'paired with the "Parent" name-value argument is ignored.'];
            warning(wid, msg)
         end

         % Might need a check similar to the original flow where the Parent,ax
         % check was only performed if H was not a figure. I am not sure why
         % that was done - maybe I thought 'Parent' was only used to supply
         % figure handles.
         % if not(wasfigure) && nargs > 0

         H = handle(args{index});
         args = args(~found);
         nargs = nargs-1;
         wasimage = isimage(H);
         wasfigure = isfig(H);
      end
   end

   % If an image was found, retrieve the axes
   if wasimage
      try
         H = imgca;
      catch e
         if strcmp(e.identifier, 'MATLAB:license:checkouterror')
            error('parsegraphics:ImageToolboxRequired', ...
               ['Image axes detected by parsegraphics. ' ...
               'Image Processing Toolbox licensing error.']);
         end
      end
   end

   % Final check - but only if a graphics object was found
   if nargs < nargin
      mustBeValidScalarGraphics(H)
   end
end

%% Helper functions
function [idx, tf] = findgraphics(varargin)
   [idx, tf] = findaxes(varargin{:});
   if isempty(idx)
      [idx, tf] = findimage(varargin{:});
   end
end

function [idx, tf] = findaxes(varargin)
   tf = cellfun(@(arg) isaxis(arg) || isfig(arg), varargin);
   idx = find(tf);
end

function [idx, tf] = findimage(varargin)
   tf = cellfun(@(arg) isimage(arg), varargin);
   idx = find(tf);
end

function [idx, tf] = findparent(varargin)

   % Case insensitive check for occurrence of 'Parent' or "Parent" in varargin.
   tf = cellfun(@(x) (isstring(x) && isscalar(x) || ...
      ischar(x) && isrow(x)) && strcmpi('parent', x), varargin);
   idx = find(tf);
end

function mustBeValidScalarGraphics(H)

   % Make sure that the graphics handle found is a scalar handle, and not an
   % empty graphics array or non-scalar graphics array.
   % Note that [] is non-scalar.
   if ~isscalar(H)
      eid = 'parsegraphics:NonScalarHandle';
      msg = 'Non-scalar handle detected by parsegraphics';
      throwAsCaller(MException(eid, msg));
   end

   % Throw an error if a deleted graphics handle is detected.
   if ~isempty(H) && ~isvalid(H)
      if isa(H, 'matlab.graphics.axis.AbstractAxes')
         eid = 'parsegraphics:DeletedAxes';
         msg = 'Deleted axes detected by parsegraphics';
         throwAsCaller(MException(eid, msg));
      else
         % It is possible for a non-Axes graphics object to get through
         % parsegraphics if passed as a Name/Value pair. Throw a different error
         % message for Axes vs. other graphics objects.
         eid = 'parsegraphics:DeletedObject';
         msg = 'Deleted object detected by parsegraphics';
         throwAsCaller(MException(eid, msg));
      end
   end
end

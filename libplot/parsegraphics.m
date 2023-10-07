function [H,args,nargs,isfigure,isimage] = parsegraphics(varargin)
   %PARSEGRAPHICS Parse graphics handles / objects from varargin-type cell array
   %
   %   [H,ARGS,NARGS,ISFIGURE,ISIMAGE] = PARSEGRAPHICS(ARG1,ARG2,...) looks for
   %   Figure or Axes provided in the input arguments. If the first argument is
   %   a figure or axes handle, it is removed from the list in ARGS and the
   %   count in NARGS. ISFIGURE is set to true if a Figure handle is detected,
   %   and false otherwise. If the first argument is an axes handle,
   %   PARSEGRAPHICS then checks the arguments for Name, Value pairs with the
   %   name 'Parent'. If a graphics object is found following the last occurance
   %   of 'Parent', then all 'Parent', Value pairs are removed from the list in
   %   ARGS and the count in NARGS. ARG1 (if it is an Axes), or the value
   %   following the last occurance of 'Parent', is returned in AX. Double
   %   handles to graphics objects are converted to graphics objects. If the
   %   handle is determined to be a handle to a deleted graphics object, an
   %   error is thrown.
   %
   % See also: isaxis, isfig, axescheck

   % This function is based on axescheck, Copyright 1984-2020 The MathWorks, Inc.

   % NOTE: isaxis and isfig are octave-compatible, but the Parent,... checks in
   % the second part of this function likely are not.

   args = varargin;
   nargs = nargin;
   isfigure = false;
   isimage = false;
   H = [];

   % Check for either a scalar numeric Figure or Axes handle, or any size array
   % of Axes or Figures. 'isgraphics' will catch numeric graphics handles, but
   % will not catch deleted graphics handles, so we need to check for both
   % separately.
   if (nargs > 0) && ( isaxis(args{1}) || isfig(args{1}) )
      isfigure = isfig(args{1});
      H = handle(args{1});
      args = args(2:end);
      nargs = nargs-1;
   end

   if ~isfigure && nargs > 0
      % Detect 'Parent' or "Parent" (case insensitive).
      inds = find(cellfun(@(x) (isStringScalar(x) || ...
         ischar(x)) && strcmpi('parent', x), args));
      if ~isempty(inds)
         inds = unique([inds inds+1]);
         pind = inds(end);

         % Check for either a scalar numeric handle, or any size array of
         % graphics objects. If the argument is passed using the 'Parent' P/V
         % pair, then we will catch any graphics handle(s), and not just Axes.
         if nargs >= pind && ...
               ((isnumeric(args{pind}) && isscalar(args{pind}) && ...
               isgraphics(args{pind})) ...
               || isa(args{pind},'matlab.graphics.Graphics'))
            H = handle(args{pind});
            args(inds) = [];
            nargs = length(args);
         end
      end
   end

   % Check for image
   if isempty(H) && isa(args{1}, 'matlab.graphics.primitive.Image')
      isimage = true;
      try
         % Passing the Image object to imgca does not work. imgca expects the
         % figure handle, which can be retrieved with imgcf, but since we want
         % to return the axes, just use imgca with no argument.
         % H = imgca(handle(args{1}));
         H = imgca;
      catch e
         if strcmp(e.identifier, 'MATLAB:license:checkouterror')
            error('MATFUNCLIB:libplot:parsegraphics:ImageToolboxRequired', ...
            'Image axes detected by parsegraphics. Image Processing Toolbox licensing error.');
         end
      end
      args = args(2:end);
      nargs = nargs-1;
   end
   
   % Make sure that the graphics handle found is a scalar handle, and not an
   % empty graphics array or non-scalar graphics array.
   if (nargs < nargin) && ~isscalar(H)
      error('MATFUNCLIB:libplot:parsegraphics:NonScalarHandle', ...
         'Non-scalar handle detected by parsegraphics');
   end

   % Throw an error if a deleted graphics handle is detected.
   if ~isempty(H) && ~isvalid(H)
      if isa(H, 'matlab.graphics.axis.AbstractAxes')
         error('MATFUNCLIB:libplot:parsegraphics:DeletedAxes', ...
            'Deleted axes detected by parsegraphics');

         % This is here as an example of how error is better than throwAsCaller,
         % because error prints the name and line number of the calling function
         % Using mcallername to achieve it is not necessary b/c error does it by
         % default. I think it might depend on whether the function is a user
         % function or a Mathworks function. MException might construct a
         % more-meaningful error message in the latter case.

         % [funcname, linenum] = mcallername();
         % throwAsCaller(MException('MATFUNCLIB:libplot:parsegraphics', ...
         %    sprintf('deleted axes detected by PARSEGRAPHICS in %s at line %d', ...
         %    upper(funcname), linenum)));
      else
         % It is possible for a non-Axes graphics object to get through the code
         % above if passed as a Name/Value pair. Throw a different error message
         % for Axes vs. other graphics objects.
         error('MATFUNCLIB:libplot:parsegraphics:DeletedObject', ...
            'Deleted object detected by parsegraphics');
      end
   end

   % add a final check on H
   isfigure = isfig(H);

   % I thought this would allow calling this function with varargin instead of
   % varargin{:} but the former returns a cell array of cell arrays. This fixes
   % the case where an empty varargin is passed in, but not otherwise.
   % This ensures an empty input args (0x0 cell array) is returned as an empty
   % 0x0 cell array rather than a 1x1 cell array containing an empty cell array.
   % if all(cellfun(@isempty, args))
   %    args = args{:};
   % end
end

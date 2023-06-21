function [H,args,nargs,isfigure] = parsegraphics(varargin)
%PARSEGRAPHICS parse graphics handles or objects from varargin-type cell array
%
%   [H,ARGS,NARGS,ISFIGURE] = PARSEGRAPHICS(ARG1,ARG2,...) looks for Figure or
%   Axes provided in the input arguments. If the first argument is a figure or
%   axes handle, it is removed from the list in ARGS and the count in NARGS.
%   ISFIGURE is set to true if a Figure handle is detected, and false otherwise.
%   If the first argument is an axes handle, PARSEGRAPHICS then checks the
%   arguments for Name, Value pairs with the name 'Parent'. If a graphics object
%   is found following the last occurance of 'Parent', then all 'Parent', Value
%   pairs are removed from the list in ARGS and the count in NARGS. ARG1 (if it
%   is an Axes), or the value following the last occurance of 'Parent', is
%   returned in AX. Double handles to graphics objects are converted to graphics
%   objects. If the handle is determined to be a handle to a deleted graphics
%   object, an error is thrown.
% 
% See also: isaxis, isfig, axescheck

% This function is based on axescheck, Copyright 1984-2020 The MathWorks, Inc.

% NOTE: isaxis and isfig are octave-compatible, but the Parent,... checks in the
% second part of this function likely are not.

args = varargin;
nargs = nargin;
isfigure = false;
H = [];

% Check for either a scalar numeric Figure or Axes handle, or any size array of
% Axes or Figures. 'isgraphics' will catch numeric graphics handles, but will
% not catch deleted graphics handles, so we need to check for both separately.
if nargs > 0 && ( isaxis(args{1}) || isfig(args{1}) )
   isfigure = isfig(args{1});
   H = handle(args{1});
   args = args(2:end);
   nargs = nargs-1;
end

if ~isfigure && nargs > 0
   % Detect 'Parent' or "Parent" (case insensitive).
   inds = find(cellfun(@(x) (isStringScalar(x) || ischar(x)) && strcmpi('parent', x), args));
   if ~isempty(inds)
      inds = unique([inds inds+1]);
      pind = inds(end);
      
      % Check for either a scalar numeric handle, or any size array of graphics
      % objects. If the argument is passed using the 'Parent' P/V pair, then we
      % will catch any graphics handle(s), and not just Axes.
      if nargs >= pind && ...
            ((isnumeric(args{pind}) && isscalar(args{pind}) && isgraphics(args{pind})) ...
            || isa(args{pind},'matlab.graphics.Graphics'))
         H = handle(args{pind});
         args(inds) = [];
         nargs = length(args);
      end
   end
end

% Make sure that the graphics handle found is a scalar handle, and not an
% empty graphics array or non-scalar graphics array.
if (nargs < nargin) && ~isscalar(H)
   throwAsCaller(MException('MATFUNCLIB:libplot:parsegraphics', 'NonScalarHandle'));
end

% Throw an error if a deleted graphics handle is detected.
if ~isempty(H) && ~isvalid(H)
   % It is possible for a non-Axes graphics object to get through the code
   % above if passed as a Name/Value pair. Throw a different error message
   % for Axes vs. other graphics objects.
   if isa(H,'matlab.graphics.axis.AbstractAxes')
      throwAsCaller(MException('MATFUNCLIB:libplot:parsegraphics','deleted axis detected'));
   else
      throwAsCaller(MException('MATFUNCLIB:libplot:parsegraphics','deleted object detected'));
   end
end

% add a final check on H
isfigure = isfig(H);

end

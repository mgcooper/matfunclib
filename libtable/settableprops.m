function T = settableprops(T, propnames, proptypes, propvals)
   %SETTABLEPROPS Assign custom properties to tabular object.
   %
   % T = settableprops(T,propnames,proptypes,propvals)
   %
   %
   % Matt Cooper, 04-May-2023, https://github.com/mgcooper
   %
   % See also: settableunits

   % Input checks
   [propnames, proptypes, propvals] = parseinputs(T, propnames, proptypes, propvals);

   % true false if the prop already exists
   hasprop = cellfun(@(prop) isprop(T, prop), propnames);

   for n = 1:numel(propnames)
      if ~hasprop(n)
         T = addprop(T, propnames{n}, proptypes{n});
      end
      T.Properties.CustomProperties.(propnames{n}) = propvals{n};
   end
end

%% Parse inputs
function [propnames, proptypes, propvals] = parseinputs(T, ...
      propnames, proptypes, propvals)
   % Let built-in addprop do most of the input checking

   % NOTE: I keep coming back here b/c the correspondence between propnames,
   % proptypes, and propvals is confusing. In general, it needs to be 1:1, but
   % for convenience I allow (as one example): propnames = 'latitude', proptypes
   % = 'variable', and propvals = [an array with one value per table variable].
   % Using addprop, it would be T = addprop(T, propname, proptype) followed by
   % T.Properties.CustomProperties.(propname) = propvals. But to also allow
   % multiple props to be set in one call to this function, I need propnames and
   % proptypes to be cell arrays so I can loop over them. So the confusion that
   % is coming up involves ensuring propnames, proptypes, and propvals are all
   % cell arrays of the same size.

   % Convert to cell if propnames is a char or string
   if ischar(propnames) || isstring(propnames)
      propnames = cellstr(propnames);
   end

   % Check if propvals is not a cell
   if ~iscell(propvals)
      % Convert non-cell scalars or tables to cell.
      if isscalar(propvals) || istabular(propvals) || isscalartext(propvals)
         propvals = {propvals};
      else
         % Convert non-cell arrays or other non-scalar objects to cell.
         % NOTE: Say propnames is a scalar text e.g. {'latitude'} and propvals
         % is a numeric array with one latitude value per variable, then
         % num2cell will create a Nx1 cell array where N = the # of variables,
         % but what is needed is a 1x1 cell array with N values. Instead of
         % changing it here, I added the next check below.
         propvals = num2cell(propvals);
      end
   end

   % If the # of property names does not match the # of values, but there is
   % just one property name, and the # of values equals the # of variables,
   % assume the property name applies to each variable.
   if numel(propnames) ~= numel(propvals)
      if numel(propnames) == 1 && numel(propvals) == width(T)
         propvals = {[propvals{:}]};
      end
   end

   % Check if the number of elements in propnames and propvals match
   assert(numel(propnames) == numel(propvals), ...
      'Number of propnames and propvals must match')

   % Allow one proptype to apply to all props
   if ischar(proptypes)
      validatestring(proptypes, {'table','variable'}, mfilename, 'proptypes', 2);
      proptypes = repmat(cellstr(proptypes), 1, numel(propnames));
   end

end


% % This was how I started to handle the checks but above might work. NOTE: this
% was here before I added the section with "if numel(propnames) == 1 &&
% numel(propvals) == width(T)".
% if numel(propnames) ~= numel(propvals) && ~iscell(propvals)
%    if isscalar(propvals) || istabular(propvals)
%       propvals = {propvals};
%    else
%       if isnumeric
%          propvals = num2cell(propvals);
%       end
%    end
% end

% % Would be nice if this worked, but the encapsulation of table in a cell
% doesn't work in the arguments block.
% arguments
%    T (:,:) table
%    propnames (1,:) string
%    propvals (1,:) cell
%    proptypes (1,:) string {mustBeMember(proptypes,{'table','variable'})} = "table"
% end
%
% % Check if the number of elements in propnames and propvals match
% assert(numel(propnames)==numel(propvals), 'Number of propnames and propvals must match')
%
% % Allow one proptype to apply to all props
% if proptypes == "table" && numel(proptypes) ~= numel(propnames)
%    proptypes = repmat(proptypes,1,numel(propnames));
% end

% BSD 3-Clause License
%
% Copyright (c) 2023, Matt Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

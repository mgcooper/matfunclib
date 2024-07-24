function dbls = cat2double(catdata, varargin)
   %CAT2DOUBLE Convert categorical data to double.
   %
   %    dbls = cat2double(catdata)
   %    dbls = cat2double(catdata, silent=true)
   %
   % This function converts a categorical array to a double array. It uses the
   % 'findgroups' function to group the categorical data and convert the group
   % identifiers to doubles. It assumes that the categorical data's categories
   % represent numeric values. The function returns a column vector of the
   % numeric equivalents of the categories in the input array.
   %
   % When converting between data types, the function aims to preserve the
   % original data as closely as possible. However, due to the limitations of
   % data type conversions, the original data might not always be recoverable.
   %
   % Note: This function handles `<missing>` and `<undefined>` values and also
   % preserves the order of ordinal categories. If any categories cannot be
   % converted to a double, the function throws an error.
   %
   % Example 1: Convert categorical array to double
   %     % Create a categorical array with duplicate values
   %     catdata = categorical([2.4 7 3 3 3 50 5 6.3 6.3 6.3 60]);
   %     % Convert to double
   %     numdata = cat2double(catdata);
   %
   % Note:
   %     str2double(catdata) % will give NaN
   %     double(catdata) % will give the underlying indices of the categories
   %     str2double(categories(catdata)) % will give the unique underlying data
   %     double(string(catdata)) % works, but will error for edge cases
   %
   % This is more "categorical"-centric, but does not provide group labels:
   %     ID = categories(catdata);
   %     numdata = str2double(ID(double(catdata)));
   %
   % Example 2: Error when categories are not numeric
   %     % Create a categorical array
   %     catdata = categorical({'A', 'B', 'C'});
   %     % Attempt to convert to double (throws error)
   %     numdata = cat2double(catdata);
   %
   % Inputs:
   %     catdata - A categorical array.
   %
   % Outputs:
   %     data - A double array, containing the numeric equivalents of the
   %            categories in catdata.
   %
   % See also: CATEGORICAL, FINDGROUPS, STR2DOUBLE

   if nargin > 1
      assert(numel(varargin) == 2)
      [check, silent] = deal(varargin{:});
      validatestring(check, {'silent'}, mfilename, 'WARNFLAG', 2);
   end

   % Ensure input is categorical
   if ~iscategorical(catdata) && ~silent
      wid = 'cat2double:InputNotCategorical';
      msg = 'Input data must be categorical, not %s';
      warning(wid, msg, class(catdata));
   end

   shape = size(catdata);

   % Obtain unique groups in the data
   [G, ID] = findgroups(catdata);

   % Try to convert categories to double
   dbls = str2double(string(ID));

   % Handle missing and undefined categories
   wasmissing = ismissing(ID);
   dbls(wasmissing) = NaN;

   % Check if all categories could be converted
   if any( isnan(dbls) & ~wasmissing )
      eid = ['custom:' mfilename ':nonNumericCategories'];
      msg = ['All categories must be convertible to double. ' ...
         'Check if there are non-numeric categories in your data.'];
      error(eid, msg);
   end

   % Map the categorical data to its numeric equivalent
   dbls = dbls(G);

   % Ensure output is a column vector
   dbls = dbls(:);
end

% BSD 3-Clause License
%
% Copyright (c) 2024, Matt Cooper (mgcooper)
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

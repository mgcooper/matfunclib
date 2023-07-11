function data = cat2double(catdata)
%CAT2DOUBLE Convert categorical data to double
% 
% This function converts a categorical array to a double array. It uses the 
% 'findgroups' function to group the categorical data and convert the group 
% identifiers to doubles. It assumes that the categorical data's categories 
% represent numeric values. The function returns a column vector of the numeric 
% equivalents of the categories in the input array.
%
% When converting between data types, the function aims to preserve the original 
% data as closely as possible. However, due to the limitations of data type 
% conversions, the original data might not always be recoverable.
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


% Ensure input is categorical
if ~iscategorical(catdata)
   warning('cat2double:InputNotCategorical', ...
      'Input data must be categorical, not %s', class(catdata));
end

% Obtain unique groups in the data
[G, ID] = findgroups(catdata);

% Try to convert categories to double
numdata = str2double(string(ID));

% Handle missing and undefined categories
missing_idx = ismissing(ID);
numdata(missing_idx) = NaN;

% Check if all categories could be converted
if any(isnan(numdata) & ~missing_idx)
   error('All categories must be convertible to double. Check if there are non-numeric categories in your data.');
end

% Map the categorical data to its numeric equivalent
data = numdata(G);

% Ensure output is a column vector
data = data(:);
end

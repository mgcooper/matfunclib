function S = addstructfields(S,fields,varargin)
%ADDSTRUCTFIELDS general description of function
% 
% Syntax
% 
%  S = ADDSTRUCTFIELDS(S,fields) adds fields to struct S using inputname(fields)
%  to name the new fields
%  S = ADDSTRUCTFIELDS(S,fields,'newfieldnames',fieldnames) uses fieldnames to
%  name the new fields
% 
% Example
%  
% 
% Matt Cooper, 06-Dec-2022, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

% validstrings      = {''}; % or [""]
% validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'S',                          @(x)isstruct(x)      );
% p.addOptional(    'option',      nan,        validoption          );
p.addParameter(   'newfieldnames',  '',         @(x)ischarlike(x)    );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

% NOTE: ddin't get far with this

% % say fields is a 10x1 array, and S is a 10x1 struct, these put the 10x1 array
% 'fields' in each row of S:
% [S.(fieldname)] = deal(fields);
% [S(:).(fieldname)] = deal(fields);
% [S(1:numel(fields)).(fieldname)] = deal(fields);
% [S(:).(fieldname)] = deal(num2cell(fields));

% % whereas this will put the individual values in each row, as desired:
% C = num2cell(fields);
% [S(:).(fieldname)] = deal(C{:});
% 
% % and these will fail:
% [S(1:numel(fields)).(fieldname)] = fields;
% [S.(fieldname)] = fields;
% S(:).(fieldname) = deal(fields);
% S.(fieldname) = deal(fields); 


% % % % % % % % % % % % % % % % % % % % 
if isempty(newfieldnames)
   newfieldnames = cellstr(inputname(2));
   
elseif ischar(newfieldnames) || isstring(newfieldnames)
   newfieldnames = cellstr(newfieldnames);
end

% add a non-scalar field to a non-scalar struct with identical # of elements,
% assume we want each element of fields to be in a row of S
if numel(S) == numel(fields) && ~isscalar(S)
   for n = 1:numel(newfieldnames)
      C = num2cell(fields);
      [S(:).(newfieldnames{n})] = deal(C{:});
   end
end

% if iscell(fields);
%    fields = fields{:};
% end


% could go about it like this:
% switch class(field)
%    
%    case 'cell'
%       [S.(fieldname)] = field{:};
%    
%    case 'double'
%       [S.(1:numfeatures).(fieldname)]  = deal(field);
% end   










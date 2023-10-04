function S = addstructfields(S, newfields, varargin)
%ADDSTRUCTFIELDS general description of function
% 
% Syntax
% 
%  S = ADDSTRUCTFIELDS(S, NEWFIELDS) adds NEWFIELDS to struct S using
%  inputname(NEWFIELDS) to name the new fields.
%  S = ADDSTRUCTFIELDS(S, NEWFIELDS, 'NEWFIELDNAMES', NAMES) uses NAMES to
%  name the new fields.
% 
% Example
%  
% 
% Matt Cooper, 06-Dec-2022, https://github.com/mgcooper
% 
% See also

% aug 2023, commented this out b/c it works and is used in baseflow project
% error([mfilename ' is not functional'])

% TODO rename assignNonScalarStructFields, might also be worth abandoning this,
% its akward, I think it is designed to assign to non-scalar structs, which is
% tricky, so 

% PARSE INPUTS
[S, newfields, newnames] = parseinputs(S, newfields, mfilename, varargin{:});

% Assign default new field names
if isempty(newnames)
   try
      newnames = cellstr(inputname(2));
   catch
      newnames = cellstr(strcat("field", string(1:numel(newfields))));
   end
   
elseif ischar(newnames) || isstring(newnames)
   newnames = cellstr(newnames);
end

% Add non-scalar fields to non-scalar struct with identical # of elements.
% Assume each element of fields is a row of S. 
if numel(S) == numel(newfields) && ~isscalar(S)
   for n = 1:numel(newnames)
      C = num2cell(newfields);
      [S(:).(newnames{n})] = deal(C{:});
   end
end

%% INPUT PARSER
function [S, newfields, newfieldnames] = parseinputs(S, newfields, funcname, varargin)

persistent parser
if isempty(parser)
   parser = inputParser;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('S', @isstruct);
   parser.addRequired('newfields'); % can be any type for now
   parser.addParameter('newfieldnames', '', @ischarlike);
end
parser.FunctionName = funcname;
parser.parse(S,newfields,varargin{:});
newfieldnames = parser.Results.newfieldnames;

%% working 

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










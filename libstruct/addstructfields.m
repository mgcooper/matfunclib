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

error([mfilename ' is not functional'])

% TODO rename assignNonScalarStructFields, might also be worth abandoning this,
% its akward, I think it is designed to assign to non-scalar structs, which is
% tricky, so 

% input parsing
persistent parser
if isempty(parser)
   parser = magicParser;
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('S', @isstruct);
   parser.addParameter('newfieldnames', '', @ischarlike);
end
parser.parseMagically('caller');


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










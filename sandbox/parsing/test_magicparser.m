function varargout = test_magicparser(a,b,varargin)
%test_magicparser 
%
%  varargout = test_magicparser
%
% See also

%% parse inputs
persistent parser
if isempty(parser)
   parser = magicParser;
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.PartialMatching = true;
   parser.addRequired('a', @isnumeric);
   parser.addRequired('b', @isnumeric);
   parser.addParameter('param',false, @islogical);
end

% [a, b, param] = parser.parseMagically(a, b, varargin{:});

% have to use this
parser.parseMagically('caller');
[a, b, param] = dealout(parser.Results);

c = a+b;

[varargout{1:nargout}] = dealout(c);
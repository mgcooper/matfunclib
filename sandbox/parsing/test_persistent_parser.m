function varargout = test_persistent_parser(a,b,varargin)
%test_persistent_parser 
%
%  varargout = test_persistent_parser(S,varargin)
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
   parser.addParameter('param', false, @islogical);
end
args = struct();
args = parser.parseMagically(args);

%% parse inputs
% persistent parser
% if isempty(parser)
%    parser = inputParser;
%    parser.FunctionName = mfilename;
%    parser.CaseSensitive=false;
%    parser.PartialMatching=true;
%    parser.addRequired('a',@isnumeric);
%    parser.addRequired('b',@isnumeric);
%    parser.addParameter('param',false,@islogical);
% end
% parse(parser, a, b, varargin{:});
% [a, b, param] = dealout(parser.Results);
% % [args{1:numfields(parser.Results)}] = dealout(parser.Results);

%%

c = a+b;
[varargout{1:nargout}] = dealout(c);
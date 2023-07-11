function [args, pairs, nargs] = parseparampairs(args)
%PARSEPARAMPAIRS return and remove name-value pairs from variable argument list.
%   
% [ARGS, PAIRS] = PARSEPARAMPAIRS(ARGS) returns ARGS, a cell array containing
% all arguments up to but excluding the first char-like argument in input cell
% array ARGS, and PAIRS, a cell array containing all other arguments after, and
% including, the first char-like argument in input cell-array ARGS.
%
% PARSEPARAMPAIRS is intended to isolate possible property value pairs in
% functions using VARARGIN as the input argument, and remove them from the
% variable arguments cell array. It does not assign property values.
% 
% See also parseoptarg, parsegraphics

[args{1:numel(args)}] = convertStringsToChars(args{:});
charargs = find( cellfun(@(a) ischar(a), args));

if isempty(charargs)
   pairs=args(1:0);
else
   pairs=args(charargs(1):end);
   args=args(1:charargs(1)-1);
end

nargs = numel(args);



% THIS IS ANOTHER VERSION FROM THE FINANCIAL TOOLBOX, NEED TO MIGRATE IT INTO
% THE ABOVE
% 
% function varargout = parsepvpairs(names, defaults, varargin)
% %PARSEPVPAIRS Validate parameter name/value pairs and throw errors if necessary.
% %   Given the cell array of valid parameter names, a corresponding cell array of
% %   parameter default values, and a variable length list of parameter name/value
% %   pairs, validate the specified name/value pairs and assign values to output
% %   parameters.
% %
% %   [P1, P2, ...] = parsepvpairs(Names, Defaults, 'Name1', Value1, 'Name2', Value2, ...)
% %
% %   Inputs:
% %      Names - Cell array of valid parameter names.
% %
% %   Defaults - Cell array of default values for the parameters named in Names.
% %
% %      Name# - Character strings of parameter names to be validated and
% %              assigned the corresponding value that immediately follows each
% %              in the input argument list. Parameter name validation is
% %              case-insensitive and partial string matches are allowed provided
% %              no ambiguities exist.
% %
% %     Value# - The values assigned to the corresponding parameter that
% %              immediately precede each in the input argument list.
% %
% %   Outputs:
% %         P# - Parameters assigned the parameter values Value1, Value2, ...
% %              in the same order as the names listed in Names. Parameters
% %              corresponding to entries in Names that are not specified in the
% %              name/value pairs are set to the corresponding value listed in
% %              Defaults.
% 
% %   Copyright 1995-2017 The MathWorks, Inc.
% 
% %
% % Short-circuit the input argument checking for performance purposes. Under the
% % following specific circumstances, users may by-pass P-V pair validation when:
% %
% % (1) Values are assigned to all recognized parameters,
% % (2) Parameters are specified in exactly the same order as in the input NAMES,
% % (3) All parameters are completely specified (i.e., exact matches and no partial 
% %     names allowed).
% %
% 
% if isequal(varargin(1:2:end-1), names)
%    varargout = varargin(2:2:end);
%    return
% end 
% 
% % Initialize some variables.
% nInputs   = length(varargin);  % # of input arguments
% varargout = defaults;
% 
% % Ensure parameter/value pairs.
% if mod(nInputs, 2) ~= 0
%    error(message('finance:parsepvpairs:incorrectNumberOfInputs'));
% 
% else
%    % Process p/v pairs.
%    for j = 1:2:nInputs
%       pName = varargin{j};
% 
%       if ~ischar(pName) && ~isstring(pName)
%          error(message('finance:parsepvpairs:nonTextString'));
%       end
% 
%       i = find(cellfun(@(x) strncmpi(pName, x, length(pName)), names));      
% 
%       if isempty(i)
%          error(message('finance:parsepvpairs:invalidParameter', pName));
% 
%       elseif length(i) > 1
%          % If ambiguities exist, check for exact match to narrow search.
%          i = find(strcmpi(pName, names));
%          if length(i) == 1
%             varargout{i} = varargin{j+1};
% 
%          else
%             error(message('finance:parsepvpairs:ambiguousParameter', pName));
%          end
% 
%       else
%          varargout{i} = varargin{j+1};
%       end
%    end
% end
% 
% 
% % [EOF]

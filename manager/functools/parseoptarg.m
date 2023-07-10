function [args, optarg, nargs] = parseoptarg(args, validoptargs, defaultopt)
%PARSEOPTARG parse optional scalar text parameter in variable argument list.
%   
% [ARGS, OPTARG, NARGS] = PARSEOPTARG(ARGS, VALIDOPTARGS, DEFAULTOPTARG) returns
% cell array OPTARG containing occurrences of VALIDOPTARGS found in ARGS,
% and returns a new version of ARGS with OPTARG removed, and NARGS, the number
% of returned arguments in ARGS. If no occurences of VALIDOPTARGS are found in
% ARGS, OPTARG is set to DEFAULTOPTARG.
%
% PARSEOPTARG is intended to isolate a single scalar text value OPTARG in
% functions using VARARGIN as the input argument, also known as a "flag".
% 
% See also parseparampairs

% Note - this is slightly more complex than the inline version I often use
% because it handles nested cells.

[args{1:numel(args)}] = convertStringsToChars(args{:});

validoptargs = tocellstr(validoptargs);

% Find possible char opts and remove the matching one if found.
for thisarg = transpose(validoptargs(:))
   iopt = cellfun(@(a) ischar(a), args);
   iopt(iopt) = cellfun(@(a) strcmp(a, thisarg), args(iopt));
   optarg = args(iopt);
   args = args(~iopt);
   nargs = numel(args);
   
   if ~isempty(optarg)
      optarg = optarg{:}; % since optarg is a scalar text, this should work
      break
   end
end

% Initialize to default arg
if isempty(optarg)
   optarg = defaultopt;
end


% % For reference, this is a bit more intuitive
% ichar = cellfun(@(a) ischar(a), args);
% iopts = cellfun(@(a) strcmp(a, optarg), args(ichar));
% iargs = ~ichar;
% iargs(ichar) = ~iopt;
% optarg = args(~iargs);
% args = args(iargs);
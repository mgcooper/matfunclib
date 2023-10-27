function [args, pairs, nargs] = parseparampairs(args, asstruct)
   %PARSEPARAMPAIRS Return and remove name-value pairs from cell argument list.
   %
   % [ARGS, PAIRS] = PARSEPARAMPAIRS(ARGS) returns ARGS, a cell array containing
   % all arguments up to but excluding the first char-like argument in input
   % cell array ARGS, and PAIRS, a cell array containing all other arguments
   % after, and including, the first char-like argument in input cell-array
   % ARGS.
   %
   % PARSEPARAMPAIRS is intended to isolate possible property value pairs in
   % functions using VARARGIN as the input argument, and remove them from the
   % variable arguments cell array. It does not assign property values.
   %
   % See also: parseoptarg, parsegraphics, cell2namedargs

   if nargin < 2
      asstruct = false;
   end
   
   [args{1:numel(args)}] = convertStringsToChars(args{:});
   charargs = find( cellfun(@(a) ischar(a), args));

   if isempty(charargs)
      pairs=args(1:0);
   else
      pairs=args(charargs(1):end);
      args=args(1:charargs(1)-1);
   end

   nargs = numel(args);
   
   if asstruct
      pairs = pvpairs2struct(pairs);
   end
end

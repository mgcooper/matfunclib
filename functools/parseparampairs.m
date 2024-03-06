function [args, pairs, nargs, rmpairs] = parseparampairs(args, rmprop, output_format)
   %PARSEPARAMPAIRS Return and remove name-value pairs from cell argument list.
   %
   % [ARGS, PAIRS] = PARSEPARAMPAIRS(ARGS) returns ARGS, a cell array containing
   % all arguments up to but excluding the first char-like argument in input
   % cell array ARGS, and PAIRS, a cell array containing all other arguments
   % after, and including, the first char-like argument in input cell-array
   % ARGS.
   %
   % [ARGS, PAIRS] = PARSEPARAMPAIRS(_, RMPROP) Removes property name and paired
   % value RMPROP.
   %
   % [ARGS, PAIRS] = PARSEPARAMPAIRS(_, 'asstruct') Returns name-value pairs in
   % a struct instead of a cell array.
   %
   % PARSEPARAMPAIRS is intended to isolate possible property value pairs in
   % functions using VARARGIN as the input argument, and remove them from the
   % variable arguments cell array. It does not assign property values.
   %
   % See also: parseoptarg, parsegraphics, cell2namedargs

   if nargin < 2 || isempty(rmprop)
      rmprop = {''};
   end
   if nargin < 3 || isempty(output_format)
      output_format = 'ascell'; % ascell or asstruct
   end

   [args{1:numel(args)}] = convertStringsToChars(args{:});
   charargs = find( cellfun(@(a) ischar(a), args));

   if isempty(charargs)
      pairs=args(1:0);
   else
      pairs=args(charargs(1):end);
      args=args(1:charargs(1)-1);
   end

   % Remove pairs if requested
   rmidx = find(cellfun(@(v) any(strcmp(v, rmprop)), pairs, 'Uniform', true));
   rmpairs = pairs(sort([rmidx, rmidx + 1]));
   pairs([rmidx, rmidx + 1]) = [];

   % Count remaining args
   nargs = numel(args);

   if strcmp(output_format, 'asstruct')
      pairs = pvpairs2struct(pairs);
   end

   % % For reference, the long form of the cellfun method
   % rmidx = false(size(pairs));
   % for n = 1:numel(pairs)
   %    if any(strcmp(pairs{n}, rmprop))
   %       rmidx(n) = true;
   %    end
   % end
   % if any(rmidx)
   %    rmidx(find(rmidx)+1) = true;
   % end
   % pairs(rmidx) = [];

end

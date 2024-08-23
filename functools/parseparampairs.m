function [args, pairs, nargs, rmpairs] = parseparampairs(args, varargin)
   %PARSEPARAMPAIRS Return and remove name-value pairs from cell argument list.
   %
   % [args, pairs, nargs, rmpairs] = parseparampairs(args)
   % [args, pairs, nargs, rmpairs] = parseparampairs(args, rmnames)
   % [args, pairs, nargs, rmpairs] = parseparampairs(args, rmnames, 'asstruct')
   %
   % [ARGS, PAIRS, NARGS] = PARSEPARAMPAIRS(ARGS) returns ARGS, a cell array
   % containing all arguments up to but excluding the first char-like argument
   % in input cell array ARGS, PAIRS, a cell array containing all arguments
   % after, and including, the first char-like argument in ARGS, and NARGS, the
   % number of arguments in the returned ARGS.
   %
   % [ARGS, PAIRS, NARGS, RMPAIRS] = PARSEPARAMPAIRS(_, RMPROPS) Removes the
   % property names RMPROPS and their paired values from PAIRS and returns them
   % in RMPAIRS. Use this syntax to return two sets of pv-pairs, one in PAIRS
   % and another in RMPAIRS. A use case for this syntax is to remove pv-pairs
   % which are incompatible with another function to which PAIRS is passed.
   %
   % % [_] = PARSEPARAMPAIRS(_, ASTYPE) Returns name-value pairs in a struct
   % array if ASTYPE is 'asstruct', and a cell array if ASTYPE is 'ascell'.
   % The default value is 'ascell'.
   %
   % PARSEPARAMPAIRS is intended to isolate possible property value pairs in
   % functions using VARARGIN as the input argument, and remove them from the
   % variable arguments cell array. It does not assign property values.
   %
   % See also: parseoptarg, parsegraphics, cell2namedargs

   % Parse the ASTYPE output-type argument. Return any arguments remaining in
   % varargin as RMPROPS (varargin should only contain ASTYPE and RMPROPS)
   [astype, rmprops, nargs] = parseoptarg(varargin, ...
      {'ascell', 'asstruct'}, 'ascell');

   % If the calling syntax is:
   % parseparampairs(varargin, 'asstruct', {'Name1', 'Name2'});
   % then rmpairs are nested inside a cell array and need to be dug out:
   if iscell(rmprops) && isscalar(rmprops) && iscell(rmprops{:})
      rmprops = rmprops{1};
   end

   if nargs < 1
      rmprops = {};
   else
      % Require that any arguments remaining in varargin are text scalars.
      assert(all(cellfun(@isscalartext, rmprops)))
   end

   % Parse the ARGS
   [args{1:numel(args)}] = convertStringsToChars(args{:});
   charargs = find( cellfun(@(a) ischar(a), args));

   if isempty(charargs)
      pairs = args(1:0);
   else
      pairs = args(charargs(1):end);
      args = args(1:charargs(1)-1);
   end

   % Remove requested pairs
   rmidx = find(cellfun(@(v) any(strcmp(v, rmprops)), pairs, 'Uniform', true));
   rmpairs = pairs(sort([rmidx, rmidx + 1]));
   pairs([rmidx, rmidx + 1]) = [];

   % Decided against this. This would require putting the argument back into
   % args. But in general, this function must be used intelligently by the
   % caller. If it detects an uneven number of pairs, the extra ones could be
   % valid positional arguments, an undocumented feature.
   %
   % % Ensure even number of elements in pairs
   % if mod(numel(pairs), 2) ~= 0
   %    warning(['Uneven number of name-value pair arguments detected. ' ...
   %       'First char-like argument will be ignored.']);
   %    pairs(1) = [];
   % end

   % Count remaining args
   nargs = numel(args);

   if strcmp(astype, 'asstruct')
      pairs = pvpairs2struct(pairs);
      rmpairs = pvpairs2struct(rmpairs);
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

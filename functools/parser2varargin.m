function namedargs = parser2varargin(p, requiredargs, option)
   %PARSER2VARARGIN Forward selected inputParser results as a varargin cell.
   %
   %  NAMEDARGS = PARSER2VARARGIN(P, REQUIREDARGS, 'notusingdefaults') returns the
   %  optional parameters in P.Results that the caller explicitly set (i.e. those
   %  NOT in P.UsingDefaults), excluding the required arguments named in the cellstr
   %  REQUIREDARGS, as a {'name', value, ...} cell.
   %
   %  NAMEDARGS = PARSER2VARARGIN(P, REQUIREDARGS, 'usingdefaults') instead returns
   %  the optional parameters that fell back to their defaults.
   %
   % The purpose is to wrap a built-in (e.g. shaperead) whose own defaults are
   % unknown: rather than mirror those defaults in the inputParser, collect only the
   % options the user actually passed and forward them with NAMEDARGS{:}, letting the
   % built-in apply its own defaults for everything else.
   %
   % See also struct2varargin, namedargs2cell, inputParser

   % Drop the required arguments; only optional parameters are forwarded. 'stable'
   % preserves P.Results field order so the emitted name/value order is predictable.
   optionalargs = setdiff(fieldnames(p.Results), requiredargs, 'stable');

   % Select the optional parameters to keep based on default usage. Using
   % P.UsingDefaults (the inputParser's own record) keeps this correct regardless of
   % where the required args sit in the field order.
   switch option
      case 'usingdefaults'
         keep = intersect(optionalargs, p.UsingDefaults, 'stable');
      case 'notusingdefaults'
         keep = setdiff(optionalargs, p.UsingDefaults, 'stable');
      otherwise
         error('matfunclib:parser2varargin:badOption', ...
            'option must be ''usingdefaults'' or ''notusingdefaults''');
   end

   % Build a name-value struct of just the kept parameters, then reuse
   % struct2varargin to convert it to {'name', value, ...} cell form.
   S = struct();
   for k = 1:numel(keep)
      S.(keep{k}) = p.Results.(keep{k});
   end
   namedargs = struct2varargin(S);
end

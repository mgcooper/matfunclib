function Tb = tablefun(fun, Ta, varargin)

   [rowsOrVars, varargin] = parseoptarg(varargin, {'rows', 'vars'}, 'vars');

   switch rowsOrVars
      case 'rows'
         try
            Tb = rowfun(fun, Ta, varargin{:});
         catch e
         end

      case 'vars'
         try
            Tb = varfun(fun, Ta, varargin{:});
         catch e
         end
   end

   % Remove the annoying "Fun_" appended to each variable name
   Tb.Properties.VariableNames = regexprep(Tb.Properties.VariableNames, ...
      'Fun_', '');
   
   % Need something like this from cellmap
   % varargout = cell(1, nargout);
   % [varargout{:}] = cellfun(fn, varargin{:}, 'UniformOutput', false);
end

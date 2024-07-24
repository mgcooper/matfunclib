function Tb = tablefun(fun, Ta, varargin)
   %TABLEFUN Like cellfun but for rowfun or varfun wrapped into one
   %
   %  Tb = tablefun(fun, Ta, 'rows')
   %  Tb = tablefun(fun, Ta, 'vars')
   %
   % See also

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

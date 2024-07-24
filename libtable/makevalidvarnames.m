function varnames = makevalidvarnames(varnames, ReplacementStyle, varargin)
   %MAKEVALIDVARNAMES Make variable names valid.
   %
   %  varnames = makevalidvarnames(varnames)
   %  varnames = makevalidvarnames(varnames, ReplacementStyle)
   %  varnames = makevalidvarnames(_, name=value)
   %
   % Description
   %
   %  varnames = makevalidvarnames(varnames) Remove leading/trailing blanks and
   %  calls matlab.lang.makeValidName with ReplacementStyle=delete.
   %
   %  varnames = makevalidvarnames(varnames, ReplacementStyle) Uses the
   %  specified ReplacementStyle. Options are 'delete', 'underscore', and 'hex'.
   %
   %  varnames = makevalidvarnames(_, name=value) passes name-value pairs to
   %  matlab.lang.makeValidName. Any name-value pair recognized by
   %  matlab.lang.makeValidName will be applied.
   %
   % Example
   %
   %  makevalidvarnames('test)1')
   %  makevalidvarnames('test)1', 'delete')
   %  makevalidvarnames('test)1', 'underscore')
   %  makevalidvarnames('test)1', 'hex')
   %
   % Compared with built-in methods:
   %  matlab.lang.makeValidName('test)1')
   %  matlab.lang.makeValidName('test)1', 'ReplacementStyle', 'delete')
   %  matlab.internal.tabular.makeValidVariableNames('test)1', 'silent') % fails
   %  makevalidvarnames('test)1')
   %
   % Using a cell array
   %  matlab.internal.tabular.makeValidVariableNames({'test)1'}, 'silent')
   %  matlab.lang.makeValidName({'test)1'}) % works
   %  makevalidvarnames({'test)1'}) % works
   %
   %
   % Updates
   % 22 Feb 2023, replaced spaces with no space instead of underscores
   %
   % See also: matlab.lang.makeValidName, matlab.lang.makeUniqueStrings,
   % matlab.internal.tabular.makeValidVariableNames

   % NOTE: if a char array is passed in like:
   % 'Var 1'
   % 'Var10'
   % 'Var11'
   %
   % and I want to deblank the first one, it won't work, when it is cast to a
   % cellstr below, the entire char array goes into one cell, and in the loop,
   % the entire char array is pulled out on n=1

   if nargin == 1
      ReplacementStyle = 'delete';
   else
      ReplacementStyle = validatestring(ReplacementStyle, ...
         {'underscore', 'delete','hex'}, mfilename, 'ReplacementStyle', 2);
   end

   % Cast inputs to cellstr for consistent handling.
   [waschar, wasstring] = deal(ischar(varnames), isstring(varnames));
   if waschar || wasstring
      varnames = {varnames};
   end
   varnames = varnames(:);

   % These are my preferred settings. Edit them if desired.
   for n = 1:numel(varnames)

      % Remove leading/trailing blanks.
      varnames{n} = strtrim(varnames{n});

      % Replace in-between blanks with _.
      switch ReplacementStyle
         case 'underscore'
            varnames{n} = strrep(varnames{n,:}, ' ', '_');
         case 'delete'
            varnames{n} = strrep(varnames{n,:}, ' ', '');

            % Note: This removes underscores in between words, which is my
            % preferred style. If you don't like this, delete this.
            varnames{n} = strrep(varnames{n,:}, '_', '');
         otherwise
            % hex or unspecified
      end

      % use the built-in function, deleting invalid chars
      varnames{n} = matlab.lang.makeValidName(varnames{n}, ...
         'ReplacementStyle', ReplacementStyle, varargin{:});
   end

   if numel(varnames) == 1
      if waschar; varnames = varnames{1}; end
      if wasstring; varnames = string(varnames{1}); end
   end
   % makeValidVariableNames uses the strtrim method used above
end

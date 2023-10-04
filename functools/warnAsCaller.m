function warnAsCaller(varargin)
   %WARNASCALLER issue warning from calling function
   %
   %
   % See also: throwAsCaller, warning


   narginchk(1,2)

   [varargin{:}] = convertStringsToChars(varargin{:});

   [ST,~] = dbstack(1, '-completenames');

   if nargin == 1
      msg = varargin{1};
      msg = sprintf('Warning in ==> %s at %d line:\n%s', ST.name, ST.line, msg);
      warning(msg);
   elseif nargin == 2
      wid = varargin{1};
      msg = varargin{2};
      msg = sprintf('Warning in ==> %s at %d line:\n%s', ST.name, ST.line, msg);
      warning(wid, msg)
   end
end

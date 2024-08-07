function out = printf(in, precision, varargin)
   %PRINTF Print floating point number(s) to the screen with specified precision
   %
   % Syntax:
   %
   % out = printf(in, precision) prints number IN to the screen with PRECISION
   %
   % out = printf(in, precision, newline) prints number IN to the screen with
   % PRECISION and appends a newline character (useful for programmatic use)
   %
   % Example:
   %
   % printf(pi,2)
   % ans =
   %     '3.14'
   %
   % printf(pi,7)
   % ans =
   %     '3.1415927'
   %
   % printf(pi,7,newline)
   %
   % @(C) Matt Cooper, 04-Nov-2022, https://github.com/mgcooper
   %
   % See also: fprintf, sprintf

   if nargin < 2
      precision = 0;
   end
   if ~iscell(in) && isnumeric(in) && isvector(in)
      in = num2cell(in);
   end

   out = cell(numel(in), 1);
   for n = 1:numel(in)
      out{n} = sprintf(['%.' int2str(precision) 'f' varargin{:}], in{n});
   end
   try
      out = vertcat(out{:});
   catch
   end
end

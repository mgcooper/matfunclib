function out = strrepin(str,varargin)
   %STRREPIN replace multiple case-insensitive substrings within a string
   %
   %   OUT = STRREPIN(STR, OLD1, NEW1, OLD2, NEW2, ...) replaces all occurrences
   %   of the string OLD1 within the string STR with the string NEW1, then
   %   replaces OLD2 with NEW2, and so on. The comparisons are case-insensitive.
   %   The function returns the result as the output OUT.
   %
   %   Inputs:
   %   STR - a string or character array where replacements are to be made
   %   OLDi - the target string or character array to be replaced
   %   NEWi - the string or character array to replace OLDi
   %
   %   Output:
   %   OUT - the output string after replacements
   %
   %   Example:
   %   strrepin('Hello World!', 'World', 'everyone', 'Hello', 'Goodbye')
   %   returns 'Goodbye everyone!'
   %
   %   Note: If STR, OLD or NEW are not provided, default values are used.
   %
   %   The function requires an even number of input arguments after STR, as
   %   they should come in pairs of OLD and NEW.
   %
   % See also: strrepi, strrep, replace

   if ~nargin
      str = 'Hello World!';
      varargin = {'World', 'everyone', 'Hello', 'Goodbye'};
   else
      assert(iseven(nargin-1), ...
         ['Invalid number of input arguments: ', num2str(nargin)]);
   end

   for i = 1 : length(varargin)/2
      str = strrepi(str, varargin{2*i-1}, varargin{2*i});
   end

   out = str;
end

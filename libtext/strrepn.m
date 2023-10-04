function out = strrepn(str,varargin)
   %STRREPN Multiple case-sensitive replacements of substrings within a string
   %
   %   OUT = STRREPN(STR, OLD1, NEW1, OLD2, NEW2, ...) replaces all occurrences
   %   of the string OLD1 within the string STR with the string NEW1, then
   %   replaces OLD2 with NEW2, and so on. The comparisons are case-sensitive.
   %   The function returns the result as the output OUT.
   %
   %   Inputs: STR - a string or character array where replacements are to be
   %   made OLDi - the target string or character array to be replaced NEWi -
   %   the string or character array to replace OLDi
   %
   %   Output: OUT - the output string after replacements
   %
   %   Example: strrepn('Hello World!', 'World', 'everyone', 'Hello', 'Goodbye')
   %   returns 'Goodbye everyone!'
   %
   %   Note: If STR, OLD or NEW are not provided, the function uses default
   %   values.
   %
   %   The function requires an even number of input arguments after STR, as
   %   they should come in pairs of OLD and NEW.
   %
   % See also: strrep, replace, strrepin, strrepi

   if ~nargin
      str = 'Hello World!';
      varargin = {'World', 'everyone', 'Hello', 'Goodbye'};
   else
      assert(iseven(nargin-1), ['Invalid number of input arguments: ', num2str(nargin)]);
   end

   for n = 1 : length(varargin)/2
      str = strrep(str, varargin{2*n-1}, varargin{2*n});
   end

   out = str;
end

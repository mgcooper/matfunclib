function S = cell2namedargs(C, allfields, varargin)
   %CELL2NAMEDARGS Convert cell array of chars to true/false options struct
   %
   %
   % Note: This function does what optionParser does using a cell array of chars
   % representing true/false "flag" arguments (which would nominally be varargin
   % in the caling function) and a cell array of all possible char flags). 
   % 
   % This is not the reverse of namedargs2cell. To do that, C should be a cell
   % array of name-value pairs, and there would be no allfields input argument.
   %
   % See also: optionParser

   S = cell2struct(num2cell(cellfun(@(arg) ismember(arg, C), ...
      allfields)), allfields, 2);
end 
function T = settablevarnames(T,varnames,varargin)
   %SETTABLEVARNAMES Set table variable names.
   %
   %  T = settablevarnames(T, VARNAMES) sets all variable names in table T to
   %  values in cell- or string-array VARNAMES. In this syntax, there must be
   %  one value in VARNAMES for each column of T.
   %
   %  T = settablevarnames(T, VARNAME, 'consecutive') sets all variable names in
   %  table T to VARNAME with the column number appended. In this mode, VARNAME
   %  can be a scalar string, cell array, or a char array, and the column number
   %  is appended such that the variable names of T are VARNAME_1, VARNAME_2,
   %  ..., VARNAME_N.
   %
   % See also

   % parse inputs
   validateattributes(T, {'table', 'timetable'}, {'nonempty'}, mfilename, 'T', 1)

   opt = 'none';
   if nargin > 2
      opt = validatestring(varargin{1}, {'consecutive'}, mfilename, 'option', 3);
   end

   % build consecutive varnames if requested
   if strcmp(opt, 'consecutive') && numel(string(varnames)) == 1
      varnames = strcat(varnames,string(1:numel(T.Properties.VariableNames)));
   else
      validateattributes(varnames, {'string', 'cell'}, ...
         {'numel', numel(T.Properties.VariableNames)}, mfilename, 'VARNAMES', 2)
   end

   % assign the new variable names
   T.Properties.VariableNames = varnames;
end
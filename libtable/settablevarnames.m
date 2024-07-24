function tbl = settablevarnames(tbl,varnames,varargin)
   %SETTABLEVARNAMES Set table variable names.
   %
   %  tbl = settablevarnames(tbl, VARNAMES) sets all variable names in table tbl to
   %  values in cell- or string-array VARNAMES. In this syntax, there must be
   %  one value in VARNAMES for each column of tbl.
   %
   %  tbl = settablevarnames(tbl, VARNAME, 'consecutive') sets all variable names in
   %  table tbl to VARNAME with the column number appended. In this mode, VARNAME
   %  can be a scalar string, cell array, or a char array, and the column number
   %  is appended such that the variable names of tbl are VARNAME_1, VARNAME_2,
   %  ..., VARNAME_N.
   %
   % See also

   % parse inputs
   validateattributes(tbl, ...
      {'table', 'timetable'}, {'nonempty'}, mfilename, 'tbl', 1)

   opt = 'none';
   if nargin > 2
      opt = validatestring(varargin{1}, {'consecutive'}, mfilename, 'option', 3);
   end

   % build consecutive varnames if requested
   if strcmp(opt, 'consecutive') && numel(string(varnames)) == 1
      varnames = strcat(varnames,string(1:numel(tbl.Properties.VariableNames)));
   else
      validateattributes(varnames, {'string', 'cell'}, ...
         {'numel', numel(tbl.Properties.VariableNames)}, mfilename, 'VARNAMES', 2)
   end

   % assign the new variable names
   tbl.Properties.VariableNames = varnames;
end

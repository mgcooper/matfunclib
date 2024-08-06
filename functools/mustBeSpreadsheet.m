function mustBeSpreadsheet(filename, callername, toolboxname)

   if nargin < 2
      callername = mcallername();
   end
   if nargin < 3
      toolboxname = 'custom';
   end

   [wasspreadsheet, ~, ext] = isspreadsheet(filename);

   eid = [toolboxname ':' callername ':expectedSpreadsheetFile'];
   msg = ['Expected ''filename'' to be a spreadsheet file, ' ...
      'instead its extension was: %s'];

   if ~wasspreadsheet
      throwAsCaller(MException(eid, msg, ext));
   end
end

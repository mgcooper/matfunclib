function opentbdirectory()
   %OPENTBDIRECTORY Open the toolbox directory spreadsheet in Excel.
   %
   %
   % See also:

   % gettbdirectorypath keeps the target absolute when the variable
   % is unset (matfunclib-47r). It runs before the open so a code or path
   % defect in it raises its own error (audit LOW 40); a failed open only
   % warns. system reports a failed open by its status, not by an error.
   dbpath = gettbdirectorypath();
   [status, output] = system(sprintf('open "%s"', dbpath));
   if status ~= 0
      warning('matfunclib:opentbdirectory:openFailed', ...
         'opentbdirectory: could not open %s (%s).', dbpath, strtrim(output));
   end
end

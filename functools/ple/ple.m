function ple(s)
   %PLE "Print Last Error"
   %
   %    ple
   %    ple(error_struct)
   %
   % Description
   %    ple() Prints information contained in the "lasterror" error struct.
   %    ple(error_struct) Uses the supplied error struct instead of lasterror.
   %
   % See also: lasterror lasterr MException

   % Copyright 2006-2010 The MathWorks, Inc.
   %
   % With updates by mgcooper (7 Aug 2024)
   % - added documentation
   % - added "isdeployed" methods by Kent Schonert

   if nargin<1
      s = lasterror; %#ok (not recommended generally, but only way to do this)
   end

   if isempty(s.message)
      fprintf(1, 'No error message stored\n');
      return;
   end

   fprintf(1, 'Last Error: %s (%s)\n', s.message, s.identifier);
   for i=1:numel(s.stack)
      e = s.stack(i);
      ff = which(e.file);
      [ignore_dir,command] = fileparts(ff); %#ok (unused output)
      n = e.name;

      if isdeployed
         href = sprintf('''%s'',%d',ff,e.line);
      else
         href = sprintf('matlab:opentoline(''%s'',%d)',ff,e.line);
      end

      if strcmp(command,n)
         % main function in this file
         if isdeployed
            fprintf(1,' %s\n',href);
         else
            fprintf(1,'    <a href="%s">%s,%d</a>\n',href,ff,e.line);
         end
      else
         % subfunction in this file
         if isdeployed
            fprintf(1,' %s >%s,%d\n',href,n,e.line);
         else
            fprintf(1,'    <a href="%s">%s >%s,%d</a>\n',href,ff,n,e.line);
         end
      end
   end
   fprintf(1,'\n');
end

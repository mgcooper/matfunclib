function varargout = code(cmd)
   %CODE pass cmd to vscode to open a project (cmd is a path)
   %
   %  msg = CODE(cmd) tries to open the folder or filename CMD in VSCode
   %
   % Matt Cooper, 09-Feb-2023, https://github.com/mgcooper
   %
   % See also

   % arguments
   %    cmd (:,:) char
   % end

   % try to find the vscode source file
   [~, codesrc] = system('which code');
   if isempty(codesrc)
      try
         % commented this out b/c I cannot find where this function is
         % [~, codesrc] = jsystem('which code');
      catch
         if ismac()
            codesrc = '/usr/local/bin/code';
         elseif ispc()
            % not sure
         else
            % not sure
         end
      end
   end
   codesrc = strrep(codesrc, newline, '');

   if nargin < 1
      cmd = '.';
   end

   try
      msg = system([codesrc ' ' cmd]);
   catch
      error('attempt to open in vscode failed')
   end

   if nargout == 1
      varargout{1} = msg;
   end
end

function copyStartupFileToFunctionPath
   %COPYSTARTUPFILETOFUNCTIONPATH Copy startup.m from userpath() to user-defined
   %env returned by getenv('MATLABFUNCTIONPATH')
   if ~isempty(userpath)
      src = fullfile(userpath,'startup.m');
   else
      error('userpath is empty');
   end
   if ~isempty(getenv('MATLABFUNCTIONPATH'))
      dst = fullfile(getenv('MATLABFUNCTIONPATH'),'startup.m');
   else
      error('MATLABFUNCTIONPATH is empty');
   end
   copyfile(src,dst)
end

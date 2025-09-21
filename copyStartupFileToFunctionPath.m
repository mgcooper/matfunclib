function copyStartupFileToFunctionPath
   %COPYSTARTUPFILETOFUNCTIONPATH Copy startup.m from userpath() to user-defined
   %env returned by getenv('MATLAB_FUNCTION_PATH')
   if ~isempty(userpath)
      src = fullfile(userpath, 'startup.m');
   else
      error('userpath is empty');
   end
   if ~isempty(getenv('MATLAB_FUNCTION_PATH'))
      dst = fullfile(getenv('MATLAB_FUNCTION_PATH'), 'startup.m');
   else
      error('MATLAB_FUNCTION_PATH is empty');
   end
   copyfile(src, dst)
end

function copyStartupFileToStartupPath()
   %COPYSTARTUPFILETOSTARTUPPATH Copy startup.m from MATLAB_FUNCTION_PATH to userpath
   %
   % Copy a version of startup.m under source control in a user-defined env
   % folder returned by getenv('MATLAB_FUNCTION_PATH') to the startup folder
   % defined by the 'userpath' function.

   src1 = fullfile(getenv('MATLAB_FUNCTION_PATH'), 'startup.m');
   src2 = fullfile(getenv('MATLAB_FUNCTION_PATH'), 'finish.m');
   if ~isempty(userpath)
      dst1 = fullfile(userpath, 'startup.m');
      dst2 = fullfile(userpath, 'finish.m');
   else
      error('userpath is empty');
   end
   copyfile(src1, dst1)
   copyfile(src2, dst2)
end

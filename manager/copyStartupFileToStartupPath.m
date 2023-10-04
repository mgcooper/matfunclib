function copyStartupFileToStartupPath()
   %COPYSTARTUPFILETOSTARTUPPATH Copy startup.m from MATLABFUNCTIONPATH to userpath
   %
   % Copy a version of startup.m under source control in a user-defined env
   % folder returned by getenv('MATLABFUNCTIONPATH') to the startup folder
   % defined by the 'userpath' function.

   src1 = fullfile(getenv('MATLABFUNCTIONPATH'), 'startup.m');
   src2 = fullfile(getenv('MATLABFUNCTIONPATH'), 'finish.m');
   if ~isempty(userpath)
      dst1 = fullfile(userpath, 'startup.m');
      dst2 = fullfile(userpath, 'finish.m');
   else
      error('userpath is empty');
   end
   copyfile(src1, dst1)
   copyfile(src2, dst2)
end

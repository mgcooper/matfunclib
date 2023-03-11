function copyStartupFileToStartupPath
%COPYSTARTUPFILETOSTARTUPPATH copy startup.m from user-defined env
%returned by getenv('MATLABFUNCTIONPATH') to userpath
src = fullfile(getenv('MATLABFUNCTIONPATH'),'startup.m');
if ~isempty(userpath)
   dst = fullfile(userpath,'startup.m');
else
   error('userpath is empty');
end
copyfile(src,dst)
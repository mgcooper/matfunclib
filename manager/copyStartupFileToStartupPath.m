function copyStartupFileToStartupPath
%COPYSTARTUPFILETOSTARTUPPATH copy startup.m from user-defined env
%returned by getenv('MATLABFUNCTIONPATH') to userpath
src = [getenv('MATLABFUNCTIONPATH') 'startup.m'];
dst = [userpath '/startup.m'];

copyfile(src,dst)
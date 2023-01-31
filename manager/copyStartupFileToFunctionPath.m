function copyStartupFileToFunctionPath
%COPYSTARTUPFILETOFUNCTIONPATH copy startup.m from userpath() to user-defined
%env returned by getenv('MATLABFUNCTIONPATH')
src = [userpath '/startup.m'];
dst = [getenv('MATLABFUNCTIONPATH') 'startup.m'];

copyfile(src,dst)
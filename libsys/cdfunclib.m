function cdfunclib
%CDFUNCLIB cd to the matlab function library

% track the starting directory (for goback)
setenv('OLD_CWD',pwd);
funcpath = getenv('MATLABFUNCTIONPATH');
cd(funcpath)
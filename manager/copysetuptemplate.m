function copysetuptemplate(destpath)

if nargin < 1
   destpath = pwd;
end
src = fullfile(getenv('MATLABTEMPLATEPATH'),'setuptemplate.m');
dst = fullfile(destpath,'Setup.m');

copyfile(src,dst);
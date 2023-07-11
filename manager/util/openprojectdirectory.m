function varargout = openprojectdirectory

projectlist = readprjdirectory;
assignin('base', 'projectlist', projectlist);
varopen projectlist;

if nargout == 1
   varargout{1} = projectlist;
end
function list = listallmfiles(folder)
   if nargin < 1
      folder = getenv('MATLAB_HOME_PATH');
   end
   if ~isfolder(folder)
      error('folder is not a folder or is not on the path')
   end
   list = getlist(folder,'*m','subdirs',true);
   list = list(~contains({list.name},'readme'));
end

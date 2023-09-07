function writeprjdirectory(projectlist)

   if isoctave
      error('writeprjdirectory is not supported in Octave.')
   end
   
   if nargin < 1
      % will be struct in octave, table in matlab
      projectlist = readprjdirectory();
   end
   
   % get the full path to projectdirectory.mat
   projectdirectorypath = getprjdirectorypath();

   % temporary backup
   tmpfile = gettmpdirectorypath();
   copyfile(projectdirectorypath, tmpfile);

   % If struct2table works in Octave, then this could be used to allow updating
   % in Octave, but test it first.
   % if isstruct(projectlist)
   %    projectstruct = projectlist;
   %    projectlist = struct2table(projectlist);
   % else
   %    projectstruct = table2struct(projectlist);
   % end
   
   % Save it
   save(projectdirectorypath, 'projectlist')

   % % old method that saved the directory as a table
   % writetable(projectlist,projectdirectorypath);
end
function makecontents(varargin)
%MAKECONTENTS make contents.m for each toolbox folder including packages
%
%
%
%
% See also


% toolbox path
tbxpath = tbx.internal.projectpath('toolbox');

% toolbox contents
% tbxlist = what(tbxpath);

% package and subpackage folders
pkglist = mpackagefolders(tbxpath, "aspathlist", true, "asstring", true);

% traverse package folders and generate a contents report in each one
for thispkg = pkglist(:).'
   processOnePackage(thispkg);
end

%% subfunction to handle each package folder individually
function processOnePackage(thispkg)

filelist = tbx.internal.filelist(thispkg, "aspathlist", true, ...
   "asstring", true, "mfiles", true);

if isempty(filelist)
   return
end

if any(strncmp(reverse(filelist), reverse("Contents.m"), 10))
   % If a Contents.m file exists in this directory, copy it to a temp file so it
   % is not included in the new Contents.m file.
   [backupfile, originalfile, tmpfile] = backupContentsFile(filelist, true);

   % If successful, copy the tmpfile to the backupfile.
   success = true;
   try
      cdobj = tbx.internal.withcd(thispkg); %#ok<NASGU> 
      tbx.internal.updatecontents;
      
      % updatecontents works but needs the Contents.m files to already exist
      % contentsrpt(char(thispkg))
      % makecontentsfile(char(thispkg))
      
      % also revisit the FSDA toolbox function:
      % makecontentsfileFS
   catch
      % otherwise restore the original file
      success = false;
      fprintf(2, 'Error occurred while generating contents for package %s. Restoring the original Contents.m\n', thispkg);
   end
   
   if success == true
      cleanupfun(tmpfile, backupfile)
   else
      cleanupfun(tmpfile, originalfile)
   end
else
   % no existing Contents file, try to make one
   try
      makecontentsfile(char(thispkg))
   catch
   end
end

%% local functions

% temporary backup file
function [bkfile, ogfile, tmpfile] = backupContentsFile(filelist, dobackup)
if dobackup
   ifile = strncmp(reverse(filelist), reverse("Contents.m"), 10);
   tmpfile = tempfile('fullpath');
   bkfile = ['Contents_' strrep(tbx.internal.getversion(),'.','') '.m'];
   ogfile = filelist(ifile);
   bkfile = fullfile(fileparts(ogfile), bkfile);
   movefile(ogfile, tmpfile)
end

function cleanupfun(tmpfile, destinationfile)
movefile(tmpfile, destinationfile);

%% oncleanup object

% To use this, it might work to put the object creation after the try-catch and
% pass it the success flag, but i think it would require storing all objects so
% they all execute at the end, which should work in this case since each object
% would know the full path to the files and the success state.

% Create a cleanup object to restore the original file in case of error
% onCleanupObj = onCleanup(@() cleanupfun(success, tmpfile, originalfile, backupfile));

% % finish the backup
% function cleanupfun(success, tmpfile, ogfile, bkfile)
% if success
%     % successful - move the temporary backup to the backup file
%     movefile(tmpfile, bkfile);
% else
%     % unsuccessful - restore the original file
%     movefile(tmpfile, ogfile);
% end

%% Notes

% runreport('contentsrpt')
% contentsrpt(thispkg)
% this is in the FSDA toolbox
% makecontentsfileFS('dirpath',thispkg,'NameOutputFile','Contents.m');

% % this would back up to the top-level internal/ dir, but then we need to track
% % whcih package or folder the Contents.m came from, so decided to not use it
% dstfolder = tbx.internal.projectpath('toolbox/internal');
%
% if ~isfolder(dstfolder)
%    fprintf( ...
%       ['%s expected %s to exist,\n' ...
%       'backing up %s to top level project folder\n'], ...
%       upper(funcname), dstfolder, filelist(ifile))
%    newfile = fullfile(tbx.internal.projectpath('toolbox'), newfile);
% else
%    newfile = fullfile(dstfolder, newfile);
% end
